from urllib.parse import urlparse
import os
import shutil
import re
import yaml
import subprocess

def extract_dependencies_from_package():
    """
    Extracts dependencies from a Package.swift file by capturing the full dependency line
    and then parsing it for the rule and version.
    
    Returns:
    - List of dictionaries containing the URL, version rule, and version constraint for each dependency.
    """
    with open('Package.swift', 'r') as file:
        package_swift_content = file.read()
    
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

def extract_products_from_package():
    """
    Extracts product dependencies from a Package.swift file by capturing the name and package 
    for each `.product` entry.

    This function reads the Package.swift file, searches for any `.product` entries using a 
    regular expression, and extracts the name and package of each product dependency. 
    Each product is stored as a dictionary with the keys `name` and `package`.
    
    Returns:
    - List of dictionaries containing the name and package for each product dependency.
    """
    with open('Package.swift', 'r') as file:
        package_swift_content = file.read()
    
    products = []
    
    # Regular expression to match .product entries
    product_pattern = re.compile(r'\.product\(name:\s*"([^"]+)",\s*package:\s*"([^"]+)"\)')
        
    # Find all matches in the file content
    matches = product_pattern.findall(package_swift_content)
    
    # Store each match as a dictionary
    for match in matches:
        name, package = match
        products.append({"name": name, "package": package})
    
    return products

def extract_binary_targets_from_package():
    """
    Extracts binary targets from a Package.swift file by capturing the name and path for each `.binaryTarget` entry.

    This function reads the Package.swift file, searches for any `.binaryTarget` entries using a regular expression,
    and extracts the name and path of each binary target. Each target is stored as a dictionary with the keys `name` and `path`.
    
    Returns:
    - List of dictionaries containing the name and path for each binary target.
    """
    with open('Package.swift', 'r') as file:
        package_swift_content = file.read()
    
    binary_targets = []
    
    # Regular expression to match .binaryTarget entries
    binary_target_pattern = re.compile(r'\.binaryTarget\(name:\s*"([^"]+)",\s*path:\s*"([^"]+)"\)')
        
    # Find all matches in the file content
    matches = binary_target_pattern.findall(package_swift_content)
    
    # Store each match as a dictionary
    for match in matches:
        name, path = match
        binary_targets.append({"name": name, "path": path})
    
    return binary_targets

def create_yml_project_file(dependencies, products, binary_targets, bundle_resources, copy_frameworks):
    """
    Generates a YAML project configuration file for the AppCoinsSDK based on input dependencies, products, binary targets, 
    bundle resources, and frameworks to copy.

    This function creates a YAML structure representing project configurations and dependencies required for AppCoinsSDK. 
    It includes specific settings for the SDK framework, such as platform, source paths, frameworks, resources, and post-build 
    scripts to embed frameworks.

    Parameters:
    - dependencies: List of dictionaries containing dependency information (e.g., URL and version rule).
    - products: List of dictionaries containing product dependencies (e.g., name and package).
    - binary_targets: List of dictionaries with binary target details (e.g., name and path).
    - bundle_resources: List of dictionaries containing bundle resources to include in the configuration.
    - copy_frameworks: List of dictionaries containing paths for frameworks to copy and embed.

    Returns:
    - Path to the generated YAML file as a string.
    """
    data = {
        'name': 'AppCoinsSDK',
        'options': {
            'bundleIdPrefix': 'com.aptoide',
            'deploymentTarget': {
                'iOS': '13.0'
            }
        },
        'settings': {
            'base': {
                'SWIFT_VERSION': '5.5',
                'CODE_SIGN_IDENTITY': "Apple Distribution",
                'DEVELOPMENT_TEAM': "26RRGP4GNA",
                'CODE_SIGN_STYLE': "Manual",
                'BUILD_LIBRARY_FOR_DISTRIBUTION': True,
                'SKIP_INSTALL': False,
                'SUPPORTED_PLATFORMS': "iphonesimulator iphoneos",
                'TARGETED_DEVICE_FAMILY': "1,2"
            }
        },
        'targets': {
            'AppCoinsSDK': {
                'type': 'framework',
                'platform': 'iOS',
                'sources': [
                    {'path': 'Sources/AppCoinsSDK'}
                ],
                'settings': {
                    'base': {
                        'INFOPLIST_FILE': 'Sources/AppCoinsSDK/Info.plist',
                        'BUILD_LIBRARY_FOR_DISTRIBUTION': True,
                        'SKIP_INSTALL': False,
                        'SUPPORTED_PLATFORMS': "iphonesimulator iphoneos",
                        'TARGETED_DEVICE_FAMILY': "1,2",
                        'CODE_SIGN_IDENTITY': "Apple Distribution",
                        'DEVELOPMENT_TEAM': "26RRGP4GNA",
                        'CODE_SIGN_STYLE': "Manual",
                    }
                },
                'options': {
                    'transitivelyLinkDependencies': False
                },
                'dependencies': [],
                'resources': [
                    {'path': 'Sources/AppCoinsSDK/Localization', 'explicit': True}
                ],
                'frameworks': [],
                'postBuildScripts': [
                    {
                        'name': "Embed Dependency Asset Bundles",
                        'script': """
                            # Find .bundle files
                            BUNDLE_FILES=$(find "${BUILT_PRODUCTS_DIR}" -maxdepth 1 -type d -name "*.bundle")
                            # Copy .bundle files to inside the generated framework
                            for BUNDLE in $BUNDLE_FILES; do
                                rsync -av --delete "${BUNDLE}" "${BUILT_PRODUCTS_DIR}/AppCoinsSDK.framework"
                            done
                        """
                    },
                    {
                        'name': "Remove .framework Files From Build Folder",
                        'script': """
                        # Find .xcframework files
                        XCFRAMEWORK_FILES=$(find "${BUILT_PRODUCTS_DIR}/AppCoinsSDK.framework" -maxdepth 1 -type d -name "*.framework")
                        # Remove .framework files from inside AppCoinsSDK.framework
                        for XCFRAMEWORK in $XCFRAMEWORK_FILES; do
                            if [ "$XCFRAMEWORK" != "${BUILT_PRODUCTS_DIR}/AppCoinsSDK.framework" ]; then
                                rm -rf "$XCFRAMEWORK"
                            fi
                        done
                        """
                    }
                ]
            },
        },
        'packages': {}
    }

    if dependencies is not None:
        for dependency in dependencies:
            data['packages'][dependency['name']] = {'url': dependency['url']}

            if dependency['rule'] == 'upToNextMinor':
                data['packages'][dependency['name']]['minorVersion'] = dependency['target']
            if dependency['rule'] == 'upToNextMajor':
                data['packages'][dependency['name']]['majorVersion'] = dependency['target']
            if dependency['rule'] == 'exact':
                data['packages'][dependency['name']]['exactVersion'] = dependency['target']
            if dependency['rule'] == 'branch':
                data['packages'][dependency['name']]['branch'] = dependency['target']

    if products is not None:
        for product in products:
            data['targets']['AppCoinsSDK']['dependencies'].append({'package': product['package'], 'product': product['name']})

    if binary_targets is not None:
        for binary_target in binary_targets:
            data['targets']['AppCoinsSDK']['dependencies'].append({'framework': binary_target['path'], 'embed': True})

    if bundle_resources is not None:
        for bundle_resource in bundle_resources:
            data['targets']['AppCoinsSDK']['resources'].append({'path': f"$(BUILT_PRODUCTS_DIR)/{bundle_resource['name']}", 'explicit': True})

    if copy_frameworks is not None:
        for copy_framework in copy_frameworks:
            data['targets']['AppCoinsSDK']['frameworks'].append({'path': f"$(BUILT_PRODUCTS_DIR)/{copy_framework['subpath']}", 'explicit': True, 'embed': True})

    yml_file_path = './project.yml'
    with open(yml_file_path, 'w') as yml_file:
        yaml.dump(data, yml_file, sort_keys=False)

    yml_file_path

def generate_xcodeproj():
    """
    Runs the xcodegen command to generate an Xcode project based on the current project.yml configuration file.

    This method triggers the command line call to `xcodegen`, which reads the `project.yml` file to create 
    an Xcode project (`.xcodeproj`) that includes all specified dependencies, targets, and resources.
    """
    subprocess.check_call(['xcodegen', 'generate'])

def resolve_package_dependencies():
    """
    Resolves package dependencies for the AppCoinsSDK Xcode project.

    This method calls `xcodebuild` with the `-resolvePackageDependencies` flag, which retrieves and caches 
    any required Swift Package Manager dependencies specified in the project.
    """
    subprocess.check_call(['xcodebuild', '-resolvePackageDependencies', '-project', 'AppCoinsSDK.xcodeproj'])

def build_for_device(device_build_path):
    """
    Builds the AppCoinsSDK framework for a physical iOS device.

    This method uses `xcodebuild` to compile the framework in Release configuration for a device, storing
    the build output in a specified path.

    Parameters:
    - device_build_path: Path where the derived data for the device build is saved.
    """
    subprocess.check_call([
        'xcodebuild', 'build',
        '-project', 'AppCoinsSDK.xcodeproj',
        '-scheme', 'AppCoinsSDK',
        '-configuration', 'Release',
        '-destination', 'generic/platform=iOS',
        '-derivedDataPath', device_build_path,
        'SKIP_INSTALL=NO',
        'BUILD_LIBRARY_FOR_DISTRIBUTION=YES',
        'OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"'
    ])

def build_for_simulator(simulator_build_path):
    """
    Builds the AppCoinsSDK framework for the iOS Simulator.

    This method compiles the framework for a simulator in Release configuration, storing the build output 
    in the specified path.

    Parameters:
    - simulator_build_path: Path where the derived data for the simulator build is saved.
    """
    subprocess.check_call([
        'xcodebuild', 'build',
        '-project', 'AppCoinsSDK.xcodeproj',
        '-scheme', 'AppCoinsSDK',
        '-configuration', 'Release',
        '-destination', 'generic/platform=iOS Simulator',
        '-derivedDataPath', simulator_build_path,
        'SKIP_INSTALL=NO',
        'BUILD_LIBRARY_FOR_DISTRIBUTION=YES',
        'OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface"'
    ])

def find_frameworks(release_directory, exclude_appc=False):
    """
    Identifies and retrieves paths to framework files in a given directory.

    This function scans the specified directory for `.framework` files, optionally excluding the AppCoinsSDK 
    framework. It also checks for any `.framework` files within a nested `PackageFrameworks` directory.

    Parameters:
    - release_directory: The directory where framework files are located.
    - exclude_appc: Boolean flag to exclude the AppCoinsSDK framework.

    Returns:
    - List of paths to detected framework files.
    """
    frameworks = []

    items_in_directory = os.listdir(release_directory)
    for item in items_in_directory:
        item_path = os.path.join(release_directory, item)
        framework_name, file_extension = os.path.splitext(item)
        if file_extension == '.framework':
            if not (exclude_appc and framework_name == 'AppCoinsSDK'):
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
    """
    Finds `.bundle` resources within a specified directory.

    This method searches through the directory structure to locate bundle resources, returning their paths.

    Parameters:
    - release_directory: The root directory to search for bundles.

    Returns:
    - List of paths to each bundle resource.
    """
    bundles = []
    for root, dirs, _ in os.walk(release_directory):
        for dir_name in dirs:
            if dir_name.endswith('.bundle'):
                bundles.append(os.path.join(root, dir_name))
    return bundles

def create_output_directories():
    """
    Creates directories to store device and simulator frameworks for final packaging.

    This method generates a base `Framework` directory along with `device` and `simulator` subdirectories. 
    These directories will store framework files compiled for devices and simulators, used to create the final `.xcframework`.

    Returns:
    - Tuple containing paths to the base framework, device, and simulator directories.
    """
    framework_directory = './Framework'
    os.makedirs(framework_directory, exist_ok=True)

    device_directory = os.path.join(framework_directory, 'device')
    os.makedirs(device_directory, exist_ok=True)

    simulator_directory = os.path.join(framework_directory, 'simulator')
    os.makedirs(simulator_directory, exist_ok=True)

    return framework_directory, device_directory, simulator_directory

if __name__ == "__main__":
    # 1. Load package dependencies
    dependencies = extract_dependencies_from_package()

    # 2. Find packages products
    products = extract_products_from_package()

    # 3. Find binary targets
    binary_targets = extract_binary_targets_from_package()

    # 4. Find .bundle resources
    # 4.1. Build a first project.yml configuration file without .bundle resources
    create_yml_project_file(dependencies, products, None, None, None)

    # 4.2 Generate xcodeproj with project.yml
    generate_xcodeproj()

    # 4.3 Resolve the dependencies for the newly created package
    resolve_package_dependencies()

    # 5.1 Build the framework for device
    device_build_path = './build/DerivedData/Device'
    build_for_device(device_build_path)

    # 5.2 Build the framework for simulator
    simulator_build_path = './build/DerivedData/Simulator'
    build_for_simulator(simulator_build_path)

    # 5.3 Create output directories, where we'll gather frameworks and produce all .xcframeworks necessary
    framework_directory, device_directory, simulator_directory = create_output_directories()

    # 5.4 Copy all dependency frameworks to output directories and generate .xcframeworks
    device_frameworks = find_frameworks(f'{device_build_path}/Build/Products/Release-iphoneos', exclude_appc = True)
    for device_framework in device_frameworks:
        shutil.copytree(device_framework, f'{device_directory}/{os.path.basename(device_framework)}')

    simulator_frameworks = find_frameworks(f'{simulator_build_path}/Build/Products/Release-iphonesimulator', exclude_appc = True)
    for simulator_framework in simulator_frameworks:
        shutil.copytree(simulator_framework, f'{simulator_directory}/{os.path.basename(simulator_framework)}')

        framework = os.path.basename(simulator_framework)
        framework_name, framework_extension = os.path.splitext(framework)

        if os.path.exists(f'{framework_directory}/{framework_name}.xcframework'):
            shutil.rmtree(f'{framework_directory}/{framework_name}.xcframework')

        subprocess.check_call(['xcodebuild', '-create-xcframework', \
                '-framework', f'{device_directory}/{framework}', \
                '-framework', f'{simulator_directory}/{framework}', \
                '-output', f'{framework_directory}/{framework_name}.xcframework'])

    # 5.5 Copy AppCoins SDK framework into the output directories
    shutil.copytree(f'{device_build_path}/Build/Products/Release-iphoneos/AppCoinsSDK.framework', f'{device_directory}/AppCoinsSDK.framework')
    shutil.copytree(f'{simulator_build_path}/Build/Products/Release-iphonesimulator/AppCoinsSDK.framework', f'{simulator_directory}/AppCoinsSDK.framework')
  
    # 5.6 Produce the output .xcframework
    framework = 'AppCoinsSDK.framework'
    framework_name, file_extension = os.path.splitext(framework)

    if os.path.exists(f'{framework_directory}/{framework_name}.xcframework'):
        shutil.rmtree(f'{framework_directory}/{framework_name}.xcframework')

    subprocess.check_call(['xcodebuild', '-create-xcframework', \
                '-framework', f'{device_directory}/{framework}', \
                '-framework', f'{simulator_directory}/{framework}', \
                '-output', f'{framework_directory}/{framework_name}.xcframework'])
    
    shutil.rmtree('./build')
    shutil.rmtree(device_directory)
    shutil.rmtree(simulator_directory)
