#include <xpcf/module/ModuleFactory.h>
#include <iostream>

namespace xpcf=org::bcom::xpcf;

/**
 *  @ingroup xpcfmodule
 */
/**
  * Declare module.
  */
XPCF_DECLARE_MODULE("%{UUID}","%{ModuleNamespace}","%{ModuleName} module description");

/**
 * This method is the module entry point.
 * XPCF uses this method to create components available in the module.
 *
 * Each component exposed must be declared inside a xpcf::tryCreateComponent<ComponentType>() call.
 */
extern "C" XPCF_MODULEHOOKS_API xpcf::XPCFErrorCode XPCF_getComponent(const xpcf::uuids::uuid& componentUUID,SRef<xpcf::IComponentIntrospect>& interfaceRef)
{
    xpcf::XPCFErrorCode errCode = xpcf::XPCFErrorCode::_FAIL;
    /* Sample code to declare components instanciation
    errCode = xpcf::tryCreateComponent<%{ModuleNamespace}::componentType>(componentUUID,interfaceRef);
    if (errCode != xpcf::XPCFErrorCode::_SUCCESS) {
        errCode = xpcf::tryCreateComponent<%{ModuleNamespace}::otherComponentType>(componentUUID,interfaceRef);
    }
    */
    return errCode;
}

/**
  * The declarations below populate list of the components available in the module (it represents the module index).
  * XPCF uses this index to introspect the components available in a module, providing the ability to generate the configuration file skeleton from the code.
  */
XPCF_BEGIN_COMPONENTS_DECLARATION
/* sample components declarations
XPCF_ADD_COMPONENT(%{ModuleNamespace}::componentType)
XPCF_ADD_COMPONENT(%{ModuleNamespace}::otherComponentType)
*/
XPCF_END_COMPONENTS_DECLARATION
