import re
import requests
from urllib.parse import urlparse
import os
from dotenv import load_dotenv
import subprocess
import yaml
import shutil

load_dotenv()

def extract_dependencies(package_swift_content):
    """
    Extracts dependencies from the content of a Package.swift file by capturing the full dependency line
    and then parsing it for the rule and version.
    
    Args:
    - package_swift_content (str): The content of the Package.swift file as a string.
    
    Returns:
    - List of dictionaries containing the URL, version rule, and version constraint for each dependency.
    """
    dependencies = []
    for line in package_swift_content.split('\n'):
        line = line.strip()
        if line[:13] == '.package(url:':
            first_open_bracket_index = line.find('(')
            last_close_bracket_index = line.rfind(')')

            content = line[first_open_bracket_index + 1 : last_close_bracket_index]
            url_raw, target_raw = content.split(',')

            first_quote_index = url_raw.find('"')
            last_quote_index = url_raw.rfind('"')
            url = url_raw[first_quote_index + 1 : last_quote_index]
            name = urlparse(url).path.split('/')[-1][:-4]

            target_raw = target_raw.strip()
            if target_raw[0] == '.':
                first_parenthesis_index = target_raw.find('(') 
                first_quote_index = target_raw.find('"')
                last_quote_index = target_raw.rfind('"') 

                rule = target_raw[1 : first_parenthesis_index]
                target = target_raw[first_quote_index + 1 : last_quote_index]
            else:
                first_colon_index = target_raw.find(':') 
                first_quote_index = target_raw.find('"')
                last_quote_index = target_raw.rfind('"')

                rule = target_raw[0 : first_colon_index]
                target = target_raw[first_quote_index + 1 : last_quote_index]
                
            dependencies.append({'name': name, 'url': url, 'rule': rule, 'target': target})

    return dependencies


def read_package_swift_file(file_path):
    """
    Reads the content of a Package.swift file.
    
    Args:
    - file_path (str): The path to the Package.swift file.
    
    Returns:
    - The content of the file as a string.
    """
    with open(file_path, 'r') as file:
        return file.read()


def get_github_tags(repo):
    """
    Fetches the tags (versions) of a GitHub repository.
    
    Args:
    - repo_url (str): The GitHub repository URL in the format "owner/repo".
    
    Returns:
    - A list of version tags.
    """
    api_url = f"https://api.github.com/repos/{repo}/tags"
    token = os.environ.get("GITHUB_TOKEN")
    headers = {'Authorization': f'token {token}'}
    response = requests.get(api_url, headers=headers)

    if response.status_code == 200:
        tags = response.json()
        return [tag['name'] for tag in tags]  # Extracting the tag names
    else:
        print(f"Error fetching tags: {response.status_code} {response.reason}")
        return []
    
def find_up_to_next_major_version(tags, current_tag):
    """
    Finds the upToNextMajorVersion for a given tag from a list of tag names.
    
    Args:
    - tags (list of str): A list of tag names (versions).
    - current_tag (str): The current tag for which to find the next major version.
    
    Returns:
    - str: The next major version or a message if the current tag is invalid.
    """
    # Define a function to parse a version string into its components
    def parse_version(version):
        strip_version = version.lstrip('v').replace("-beta", "").replace("-alpha", "")
        parts = re.split(r'\.|-RC', strip_version)
        
        parts_list = list(map(int, parts))  # Convert parts to integers
        
        padding = 4 - len(parts_list)
        for pad in range(padding):
            parts_list.append(0)
        
        return parts_list

    # Check if the current tag is in the list
    if current_tag not in tags:
        return "Current tag not found in the list."

    # Parse the current tag
    current_major, current_minor, current_patch, current_minor_patch = parse_version(current_tag)

    next_major_version = current_tag
    parsed_next_major_version = [current_major, current_minor, current_patch, current_minor_patch]
    for tag in tags:
        major, minor, patch, minor_patch = parse_version(tag)
        if major == parsed_next_major_version[0]:
            if minor > parsed_next_major_version[1] or \
                (minor == parsed_next_major_version[1] and patch > parsed_next_major_version[2]) or \
                (minor == parsed_next_major_version[1] and patch == parsed_next_major_version[2] and minor_patch > parsed_next_major_version[3]):
                next_major_version = tag
                parsed_next_major_version = [major, minor, patch, minor_patch]
    
    return next_major_version

def find_up_to_next_minor_version(tags, current_tag):
    """
    Finds the upToNextMinorVersion for a given tag from a list of tag names, 
    excluding the next minor version if it exists in the list.
    
    Args:
    - tags (list of str): A list of tag names (versions).
    - current_tag (str): The current tag for which to find the next minor version.
    
    Returns:
    - str: The upToNextMinorVersion or a message if the current tag is invalid.
    """
    # Define a function to parse a version string into its components
    def parse_version(version):
        strip_version = version.lstrip('v').replace("-beta", "").replace("-alpha", "")
        parts = re.split(r'\.|-RC', strip_version)
        
        parts_list = list(map(int, parts))  # Convert parts to integers
        
        padding = 4 - len(parts_list)
        for pad in range(padding):
            parts_list.append(0)
        
        return parts_list

    # Check if the current tag is in the list
    if current_tag not in tags:
        return "Current tag not found in the list."

    # Parse the current tag
    current_major, current_minor, current_patch, current_minor_patch = parse_version(current_tag)

    next_minor_version = current_tag
    parsed_next_minor_version = [current_major, current_minor, current_patch, current_minor_patch]
    for tag in tags:
        major, minor, patch, minor_patch = parse_version(tag)
        if major == parsed_next_minor_version[0] and minor == parsed_next_minor_version[1]:
            if patch > parsed_next_minor_version[2] or (patch == parsed_next_minor_version[2] and minor_patch > parsed_next_minor_version[3]):
                next_minor_version = tag
                parsed_next_minor_version = [major, minor, patch, minor_patch]
    
    return next_minor_version

def download_github_repo(repo_url, target_dir, branch_or_tag):
    """
    Clones a GitHub repository by branch or version tag.
    
    Args:
    - repo_url (str): The GitHub repository URL (e.g., "https://github.com/owner/repo.git").
    - target_dir (str): The local directory to clone the repository into.
    - branch_or_tag (str): The branch name or version tag to checkout after cloning.
    
    Returns:
    - None
    """
    try:
        # Clone the repository
        subprocess.check_call(['git', 'clone', repo_url, target_dir])
        
        # Change to the target directory
        os.chdir(target_dir)
        
        # Checkout the specified branch or tag
        subprocess.check_call(['git', 'checkout', branch_or_tag])

        os.chdir('..')
        os.chdir('..')
        
        print(f"Successfully cloned and checked out {branch_or_tag} from {repo_url} into {target_dir}.")
    except subprocess.CalledProcessError as e:
        print(f"Error during cloning or checking out: {e}")

def modify_library_products(content: str, product_type: str) -> str:
    # Regex pattern to find .library products and insert type as an argument
    product_pattern = r'(\.library\(\s*name:\s*"[^"]+",\s*targets:\s*\[\s*"[^"]+"\s*\])'
    modified_content = re.sub(product_pattern, r'\1,\n            type: .dynamic', content)
    return modified_content

def create_yml_project_file(dependencies):
    # Data structure representing the .yml file content
    data = {
        'name': 'AppCoinsSDK',
        'options': {
            'bundleIdPrefix': 'com.aptoide',
            'deploymentTarget': {
                'iOS': '14.0'
            }
        },
        'settings': {
            'base': {
                'SWIFT_VERSION': '5.5',
                'CODE_SIGN_IDENTITY': "iPhone Developer",
                'CODE_SIGN_STYLE': "Automatic",
            }
        },
        'targets': {
            'AppCoinsSDK': {
                'type': 'framework',
                'platform': 'iOS',
                'sources': ['Sources/AppCoinsSDK'],
                'resources': ['Sources/AppCoinsSDK/Localization'],
                'settings': {
                    'base': {
                        'INFOPLIST_FILE': 'Sources/AppCoinsSDK/Info.plist'
                    }
                },
                'options': {
                    'transitivelyLinkDependencies': True
                },
                'dependencies': [
                    {'target': 'IndicativeLibrary'},
                    {'framework': 'Sources/AppCoinsSDK/Frameworks/PPRiskMagnes.xcframework'}
                ]
            },
            'IndicativeLibrary': {
                'type': 'framework',
                'platform': 'iOS',
                'sources': ['Sources/Indicative'],
                'publicHeadersPath': 'Sources/Indicative/Headers',
                'settings': {
                    'base': {
                        'HEADER_SEARCH_PATHS': 'Sources/Indicative/Headers',
                        'DEFINES_MODULE': 'YES'
                    }
                }
            }
        },
        'packages': {}
    }

    for dependency in dependencies:
        data['targets']['AppCoinsSDK']['dependencies'].append({'package': dependency['name']})
        data['packages'][dependency['name']] = {'path': dependency['path']}

    # Write the data to a .yml file
    yml_file_path = './project.yml'
    with open(yml_file_path, 'w') as yml_file:
        yaml.dump(data, yml_file, sort_keys=False)

    yml_file_path

def find_frameworks(release_directory):
    frameworks = []

    items_in_directory = os.listdir(release_directory)
    for item in items_in_directory:
        item_path = os.path.join(release_directory, item)
        framework_name, file_extension = os.path.splitext(item)
        if file_extension == '.framework':
            frameworks.append(item_path)

    package_frameworks_directory = os.path.join(release_directory, 'PackageFrameworks')
    package_frameworks = os.listdir(package_frameworks_directory)
    for framework in package_frameworks:
        framework_path = os.path.join(package_frameworks_directory, framework)
        package_name, package_extension = os.path.splitext(framework)
        if package_extension == '.framework':
            frameworks.append(framework_path)

    return frameworks

def find_bundles(release_directory):
    bundles = []
    items_in_directory = os.listdir(release_directory)
    for item in items_in_directory:
        item_path = os.path.join(release_directory, item)
        bundle_name, file_extension = os.path.splitext(item)
        if file_extension == '.bundle':
            bundles.append(item_path)

    return bundles

if __name__ == "__main__":

    # subprocess.check_call(['xcodegen', 'generate'])

    # subprocess.check_call(['xcodebuild', '-resolvePackageDependencies', '-project', 'AppCoinsSDK.xcodeproj'])

    # # Build the framework for both platforms (iOS and iOS Simulator)
    # device_build_path = './build/DerivedData/Device'
    # simulator_build_path = './build/DerivedData/Simulator'

    # # Build for iOS Device
    # subprocess.check_call([
    #     'xcodebuild', 'build',
    #     '-project', 'AppCoinsSDK.xcodeproj',
    #     '-scheme', 'AppCoinsSDK',
    #     '-configuration', 'Release',
    #     '-destination', 'generic/platform=iOS',
    #     '-derivedDataPath', device_build_path,
    #     'SKIP_INSTALL=NO',
    #     'BUILD_LIBRARY_FOR_DISTRIBUTION=YES',
    #     'OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"'
    # ])

    # # Build for iOS Simulator
    # subprocess.check_call([
    #     'xcodebuild', 'build',
    #     '-project', 'AppCoinsSDK.xcodeproj',
    #     '-scheme', 'AppCoinsSDK',
    #     '-configuration', 'Release',
    #     '-destination', 'generic/platform=iOS Simulator',
    #     '-derivedDataPath', simulator_build_path,
    #     'SKIP_INSTALL=NO',
    #     'BUILD_LIBRARY_FOR_DISTRIBUTION=YES',
    #     'OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"'
    # ])

    # Find xcframeworks in the DerivedData build directory
    device_frameworks = find_frameworks('./build/DerivedData/Device/Build/Products/Release-iphoneos/')
    print(f'Device Frameworks: {device_frameworks}')

    # Find bundle resources in the DerivedData build directory
    device_bundles = find_bundles('./build/DerivedData/Device/Build/Products/Release-iphoneos/')
    print(f'Device Bundles: {device_bundles}')

    # Find xcframeworks in the DerivedData build directory
    simulator_frameworks = find_frameworks('./build/DerivedData/Simulator/Build/Products/Release-iphonesimulator/')
    print(f'Simulator Frameworks: {simulator_frameworks}')

    # Find bundle resources in the DerivedData build directory
    simulator_bundles = find_bundles('./build/DerivedData/Simulator/Build/Products/Release-iphonesimulator/')
    print(f'Simulator Bundles: {simulator_bundles}')

    xcframework_directory = './xcframework'
    os.makedirs(xcframework_directory, exist_ok=True)

    device_directory = os.path.join(xcframework_directory, 'device')
    os.makedirs(device_directory, exist_ok=True)

    simulator_directory = os.path.join(xcframework_directory, 'simulator')
    os.makedirs(simulator_directory, exist_ok=True)

    # for device_framework in device_frameworks:
    #     shutil.copytree(device_framework, f'{device_directory}/{os.path.basename(device_framework)}')

    #     if os.path.basename(device_framework) == 'AppCoinsSDK.framework':
    #         for device_bundle in device_bundles:
    #             shutil.copytree(f'{device_directory}/{os.path.basename(device_framework)}', f'{device_directory}/{os.path.basename(device_framework)}/{os.path.basename(device_bundle)}')

    # for simulator_framework in simulator_frameworks:
    #     shutil.copytree(simulator_framework, f'{simulator_directory}/{os.path.basename(simulator_framework)}')

    #     if os.path.basename(simulator_framework) == 'AppCoinsSDK.framework':
    #         for simulator_bundle in simulator_bundles:
    #             shutil.copytree(f'{simulator_directory}/{os.path.basename(simulator_framework)}', f'{simulator_directory}/{os.path.basename(simulator_framework)}/{os.path.basename(simulator_bundle)}')

    for device_framework in device_frameworks:
        framework = os.path.basename(device_framework)
        framework_name, file_extension = os.path.splitext(framework)

        subprocess.check_call(['xcodebuild', '-create-xcframework', \
                    '-framework', f'{device_directory}/{framework}', \
                    '-framework', f'{simulator_directory}/{framework}', \
                    '-output', f'{xcframework_directory}/{framework_name}.xcframework'])

    # subprocess.check_call(['xcodebuild', 'archive', \
    #                         '-project', 'AppCoinsSDK.xcodeproj', \
    #                         '-scheme', 'AppCoinsSDK', \
    #                         '-configuration', 'Release', \
    #                         '-destination', 'generic/platform=iOS', \
    #                         '-archivePath', './build/AppCoinsSDK.xcarchive', \
    #                         'SKIP_INSTALL=NO', \
    #                         'BUILD_LIBRARY_FOR_DISTRIBUTION=YES', \
    #                         'OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"'
    #                         ])
    
    
    


    #     # package_path = f'{repo_dir}/Package.swift'
    #     # package_swift_content = read_package_swift_file(package_path)
    #     # modified_swift_content = modify_library_products(package_swift_content, product_type='.dynamic')

    # file_path = "Package.swift"
    # package_swift_content = read_package_swift_file(file_path)
    # dependencies = extract_dependencies(package_swift_content)

    # for dependency in dependencies:
    #     repo_url = dependency['url']
    #     repo_name = dependency['name']
    #     repo = urlparse(repo_url).path[1:-4]
    #     tags = get_github_tags(repo)

    #     rule = dependency['rule']
    #     target = dependency['target']
    #     if rule == 'upToNextMinor':
    #         target = find_up_to_next_minor_version(tags, target)
    #     if rule == 'upToNextMajor':
    #         target = find_up_to_next_major_version(tags, target)
    #     if rule == 'branch':
    #         target = target
    #     if rule == 'exact':
    #         target = target

    #     repo_dir = f'dependencies/{repo_name}'
    #     os.makedirs(repo_dir, exist_ok=True)

    #     dependency['path'] = repo_dir

        # download_github_repo(repo_url, repo_dir, target)

    # # create_yml_project_file(dependencies)


