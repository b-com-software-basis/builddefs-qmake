%{Cpp:LicenseTemplate}\
#ifndef %{GUARD}
#define %{GUARD}


@if '%{Base}' && '%{Base}' !== 'None'
#include "%{Base}.h"
@else
#include <xpcf/api/IComponentIntrospect.h>
@endif

%{JS: Cpp.openNamespaces('%{Class}')}

@if '%{Base}' && '%{Base}' !== 'None'
class %{CN} : virtual public %{Base}
@else
class %{CN}: virtual public org::bcom::xpcf::IComponentIntrospect
@endif
{
public:
    virtual ~%{CN}() override = default;
};

%{JS: Cpp.closeNamespaces('%{Class}')}

template <> struct org::bcom::xpcf::InterfaceTraits<%{Class}>
{
    static constexpr const char * UUID = "%{UUID}";
    static constexpr const char * NAME = "%{CN}";
    static constexpr const char * DESCRIPTION = "%{CN} interface description";
};

#endif // %{GUARD}\
