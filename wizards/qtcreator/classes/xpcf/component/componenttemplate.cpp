%{Cpp:LicenseTemplate}\
#include "%{HdrFileName}"

namespace xpcf = org::remaken::xpcf;

template<> %{Class} * xpcf::ComponentFactory::createInstance<%{Class}>();

%{JS: Cpp.openNamespaces('%{Class}')}

%{CN}::%{CN}():xpcf::%{BaseComponentClass}(xpcf::toMap<%{CN}>())
{
    @if '%{Base}' && '%{Base}' !== 'None'
    declareInterface<%{Base}>(this);
    @endif
    //  Inject declarations come here : declare any component that must be injected to your component through its interface /////////////////////////..///// declareInjectable<IFilter>(m_filter);
    //
    // Inject declaration can have a name :
    // declareInjectable<IFilter>(m_blurFilter, "blurFilter");
    //
    // Inject declaration can be optional i.e. not finding a binding component for the interface is not an error :
    // declareInjectable<IImageFilter>(m_imageFilter, false);

    @if '%{BaseComponentClass}' === 'ConfigurableBase'
    // wrap any component member variable to expose as properties with declareProperty<T>() with T matching the variable type
    // For example : declareProperty<float>("blurFactor",m_blurFactor);
    // declareProperty("name",m_memberVariable) also works with template type deduction when m_memberVariable is a supported type of IProperty
   @endif
}


%{CN}::~%{CN}()
{

}

void %{CN}::unloadComponent ()
{
  // provide component cleanup strategy
  // default strategy is to delete self, uncomment following line in this case :
  // delete this;
  return;
}

@if '%{BaseComponentClass}' === 'ConfigurableBase'
xpcf::XPCFErrorCode %{CN}::onConfigured()
{
    // Add custom onConfigured code
    return xpcf::XPCFErrorCode::_SUCCESS;
}
@endif

%{JS: Cpp.closeNamespaces('%{Class}')}\
