require 'spec_helper'

describe 'knot' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "knot class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily,
        }}

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_class('knot::params') }
        it { is_expected.to contain_class('knot::install').that_comes_before('knot::config') }
        it { is_expected.to contain_class('knot::config') }
        it { is_expected.to contain_class('knot::service').that_subscribes_to('knot::config') }

        it { is_expected.to contain_service('knot') }
        it { is_expected.to contain_package('knot').with_ensure('present') }
      end
    end
  end

  context 'unsupported operating system' do
    describe 'knot class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('knot') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
