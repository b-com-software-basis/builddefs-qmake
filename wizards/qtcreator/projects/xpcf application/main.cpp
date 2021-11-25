#include <xpcf/xpcf.h>
#include <iostream>

namespace xpcf=org::bcom::xpcf;


/**
  * Declare module.
  */
int main(int argc, char ** argv)
{
    SRef<xpcf::IComponentManager> xpcfComponentManager = xpcf::getComponentManagerInstance();
    xpcf::XPCFErrorCode err = xpcfComponentManager->load();
    /* sample component resolution
      SRef<InterfaceType> component = xpcfComponentManager->resolve<InterfaceType>();
    */
    // call InterfaceType methods below
    //...
    return 0;
}
