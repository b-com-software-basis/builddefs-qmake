# Builddefs-qmake documentation
TODO

## Packaging structure

### Default behavior
TODO

### Package tree
	package_name/package_version/
	package_name-package_version_remakeninfo.txt (or libname ??)
	bcom-package_name.pc (should be renamed to remaken-*.pc ?)
	interfaces/
	lib/[arch]/[mode]/[config]/


### Package metadata
An information file is created in the target package. The file is named ```[TARGET]-[VERSION]_remakeninfo.txt```

It contains the following informations :

- ```platform``` : the supported compiler/platform version
- ```cppstd``` : the c++ standard used
- ```runtime``` : the runtime used (windows flag indicating whether the target uses the static or the dynamic runtime)

### Dependencies declaration file
For each project, a ```packagedependencies.txt``` file can be created in the root project folder.

Each line follows the pattern :

	framework#channel|version|library name [% condition1 [% condition2]]...|identifier@repository_type|repository_url|link_mode|options

where ```repository_type``` is a value in:

- b-com
- github
- vcpkg
- conan
- system
- path : local or network filesystem root path hosting the dependencies

Conditions separated with % are compilation defined flags (i.e. -DCOMPILFLAG) used to toggle the dependency.
It allows to build the package with several features enabled or not, and uses the underlying dependencies only when the feature is set.

Conditions are set in the "library name" section, after the library name

```link_mode``` is an optional value in :

- static
- shared
- default (inherits the project's link mode)
- na (not applicable)

When ```link_mode``` is not provided :

- For remaken (b-com and github), system and vcpkg dependencies link_mode is set to "default"
- For conan, link_mode is set to "na"

**Conan note**: 
>```link_mode``` is mandatory if the targeted dependency needs the option. When ```link_mode``` is not provided or is set to ```na```, it is not forwarded to conan, has some packages (typically header only libraries) don't define this option and setting the option leads to an error.

When ```repository_type``` is not specified :

- it defaults to b-com when identifier is either ```bcomBuild``` or ```thirdParties``` (and in this case, the identifier is also the destination subfolder where the dependencies are installed)
- it defaults to system when identifier is one of yum, apt, pkgtool, pkgutil, brew, macports, pacman, choco, zypper

For other repository types (github, vcpkg, conan, system) when the identifier matches the repository type,
the repository type reflects the ```identifier``` value - i.e. ```identifier``` = conan means ```repository_type``` is set to conan.

When ```identifier``` is not specified :

- @repository_type is mandatory

When ```channel``` is not specified, it defaults to stable for conan dependencies.

For b-com and github repositories, ```channel``` can be a combination of values from the remaken packaging manifest.
It is not used for other kind of repos.

Options are directly forwarded to the underlying repository tool.

**Note** :

>To provide specific options to dedicated system packaging tools, use one line for each specific tool describing the dependency. 

>(once installed, system dependencies should not need specific options declarations during dependencies' parsing at project build stage. Hence the need for the below sample should be close to 0, except for packaging tools that build package upon install such as brew and macports and where build options can be provided).

>For instance :

	eigen|3.3.5|eigen|system|https://github.com/SolarFramework/binaries/releases/download
	eigen|3.3.5|eigen|brew@system|https://github.com/SolarFramework/binaries/releases/download|default|-y
	eigen|3.3.5|eigen|pkgtool@system|https://github.com/SolarFramework/binaries/releases/download|default|--S --noconfirm


### Sample repositories declarations :

	opencv|3.4.3|opencv|thirdParties|https://github.com/SolarFramework/binaries/releases/download
	xpcf|2.1.0|xpcf|bcomBuild|https://github.com/SolarFramework/binaries/releases/download|static|
	spdlog|0.14.0|spdlog|thirdParties@b-com|https://github.com/SolarFramework/binaries/releases/download
	eigen|3.3.5|eigen|system|https://github.com/SolarFramework/binaries/releases/download
	fbow|0.0.1|fbow|vcpkg|https://github.com/SolarFramework/binaries/releases/download
	boost|1.68.0|boost|conan|https://github.com/SolarFramework/binaries/releases/download
	freeglut#testing|3.0.0|freeglut|user@conan|https://github.com/SolarFramework/binaries/releases/download

- github, b-com and path dependencies are installed using remaken packaging format through an url or filesystem repository.
- System dependencies are installed using operating system dependent package manager (apt for linux debian and derivatives, brew for Mac OS X, chocolatey for windows...)
- Conan dependencies are installed using packaging format with conan package manager
- Vcpkg dependencies are installed using vcpkg packaging format with vcpkg package manager

**WARNING** : 
>using system without any OS option implies the current system the tool is run on.
Moreover, some OSes don't have a package manager, hence don't rely on system for android cross-compilation for instance.

## Qmake informations

### Common project structure
- ```TARGET``` : defines the project name, usually final binary name
- ```FRAMEWORK``` : defines a common package name for several libraries
- ```INSTALLSUBDIR``` : defines an install subdirectory for package home directory
- ```VERSION``` : defines version of the project

include ```template*.pri``` file (after ```TARGET```, ```FRAMEWORK```, ```INSTALLSUBDIR```, ```VERSION``` declarations)

### Define configuration

```CONFIG``` defines how to build the current target :

- [```static``` | ```staticlib```] builds the target as a static library/application
- [```shared``` | ```dll```] builds the target as a static library/application

```DEPENDENCIESCONFIG``` defines how to search and which dependencies to use :

- [```sharedlib``` | ```shared```] search and use dependencies as shared libraries
- [```staticlib``` | ```static```] search and use dependencies as static libraries
- [```recursive``` | ```recurse```] search dependencies recursively from other remaken packagedependencies information files
- [```install```] install first level shared dependencies with the target
- [```install_recurse```] search dependencies recursively (see [```recursive```]) and install all shared dependencies with the target

### Ignore dependencies install
To ignore some specific dependencies install, define a ```packageignoreinstall.txt``` file in the root project folder.

Define each framework ignored (as defined in packagedependencies.txt) with the pattern :

	framework1 framework2

or

	framework1 
	framework2

### Use project with Qt Vs Tools

```Qt Vs tools``` is a Visual Studio plugin for manage a qmake project in Visual Studio by generating a msvc project

- [Information link](https://doc.qt.io/qtvstools/index.html)
- [Download link](https://download.qt.io/development_releases/vsaddin/)

Define project for use with Qt Vs Tools :

	PROJECTCONFIG = QTVS
allows to enable debug and release configurations, install of the package, ```DEPENDENCIESCONFIG``` flags ```install``` or ```install_recurse``` in msvc project generated 

To manage ```install``` or ```install_recurse``` with QTVS, include ```remaken_install_target.pri``` at the end od the .pro file

declare QTVS config before include ```template*.pri``` file

### Product information
Defined in _ProductConfig.pri local project file

	PRODUCT_NAME
	PRODUCT_DESCRIPTION
	PRODUCT_MANUFACTURER	  		sample = b<>com
	PRODUCT_MANUFACTURERCODE		bCom
	PRODUCT_GUID					example = 5855BF98-D32C-414C-BCA3-860BB8B4576E
	
	PRODUCT_VERSIONCODE				hexadecimal based versioning
	PRODUCT_VERSION					derived from project $${VERSION}
	PRODUCT_VERSIONSTRING			derived from project "$${VERSION}"

### Library Target
TODO

### Application Target
TODO

### Bundle/plugin Target
TODO

# Audio plugins specific files/variables
TODO
## _JuceConfig.pri local project file
Starts with ```_ProductConfig.pri``` inclusion
## Declare which plugin format(s) to build

```QMAKE_JUCEAUDIOCONFIG``` defines the audio plugin formats to be built (sample : juceAU juceVST juceAAX juceVST3)
Supported values:

For each format declared in QMAKE_JUCEAUDIOCONFIG, the plugin category must be defined, for instance :

	JUCEPLUGIN_CATEGORY.juceAU = kAudioUnitType_Effect
	JUCEPLUGIN_CATEGORY.juceAUv3 = kAudioUnitType_Effect
	JUCEPLUGIN_CATEGORY.juceVST = kPlugCategSpacializer
	JUCEPLUGIN_CATEGORY.juceVST3 = kPlugCategSpacializer
	JUCEPLUGIN_CATEGORY.juceAAX = AAX_ePlugInCategory_SoundField
	JUCEPLUGIN_AUV3TAGS = Effects

The plugin code is a 4 digit code and must be defined

	JUCEPLUGIN_PLUGINCODE#"H2Sk"

	JUCEPLUGIN ...
	PRODUCTNAME, PRODUCTNAME_SHORT vs TARGET
