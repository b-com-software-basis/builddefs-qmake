%{Cpp:LicenseTemplate}\
#ifndef %{GUARD}
#define %{GUARD}
@if '%{BaseComponentClass}' === 'ConfigurableBase'
#include <xpcf/component/ConfigurableBase.h>
@else
#include <xpcf/component/ComponentBase.h>
@endif

@if '%{Base}' && '%{Base}' !== 'None'
#include "%{JS: Cpp.classToFileName('%{Base}', '%{JS: Util.preferredSuffix('text/x-c++hdr')}')}"
@endif

%{JS: Cpp.openNamespaces('%{Class}')}

@if '%{Base}' && '%{Base}' !== 'None'
class %{CN} : public org::remaken::xpcf::%{BaseComponentClass}, virtual public %{Base}
@else
class %{CN}: public org::remaken::xpcf::%{BaseComponentClass}
@endif
{
public:
    %{CN}();
    ~%{CN}() override;
    void unloadComponent () override;

    @if '%{BaseComponentClass}' === 'ConfigurableBase'
    org::remaken::xpcf::XPCFErrorCode onConfigured() override;
    @endif
};


%{JS: Cpp.closeNamespaces('%{Class}')}

template <> struct org::remaken::xpcf::ComponentTraits<%{Class}>
{
    static constexpr const char * UUID = "%{UUID}";
    static constexpr const char * NAME = "%{CN}";
    @if '%{Base}'
    static constexpr const char * DESCRIPTION = "%{CN} implements %{Base} interface";
    @else
    static constexpr const char * DESCRIPTION = "%{CN} component description";
    @endif
};

#endif // %{GUARD}\
