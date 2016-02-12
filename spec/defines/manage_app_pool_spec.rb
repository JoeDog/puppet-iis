require 'spec_helper'

describe 'iis::manage_app_pool', :type => :define do
  describe 'when managing the iis application pool' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) {{
      :enable_32_bit           => true,
      :managed_runtime_version => 'v4.0',
      :managed_pipeline_mode   => 'Integrated',
      :apppool_identitytype    => 'ApplicationPoolIdentity'
    }}

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 true",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'true\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Integrated') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity').with(
      :command => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;\$pool.processModel.identityType = 4;\$pool | set-item;",
      :unless  => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;if(\$pool.processModel.identityType -eq \"ApplicationPoolIdentity\"){exit 0;}else{exit 1;}",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end

  describe 'when managing the iis application pool with SpecificUser identitytype' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) {{
      :enable_32_bit           => true,
      :managed_runtime_version => 'v4.0',
      :managed_pipeline_mode   => 'Integrated',
      :apppool_identitytype    => 'SpecificUser',
      :apppool_username		   => 'username',
      :apppool_userpw		   => 'password'
    }}

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 true",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'true\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Integrated') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username').with(
      :command => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;\$pool.processModel.username = \"username\";\$pool.processModel.password = \"password\";\$pool.processModel.identityType = 3;\$pool | set-item;",
      :unless  => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;if(\$pool.processModel.identityType -ne \"SpecificUser\"){exit 1;}\
if(\$pool.processModel.userName -ne username){exit 1;}if(\$pool.processModel.password -ne password){exit 1;}exit 0;",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }
  end

  describe 'when managing the iis application pool - v2.0 Classic' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) {{
      :enable_32_bit           => true,
      :managed_runtime_version => 'v2.0',
      :managed_pipeline_mode   => 'Classic'
    }}

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v2.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v2.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 true",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'true\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 1",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Classic') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }
    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end

  describe 'when managing the iis application pool - v2.0 Classic with SpecificUser identitytype' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) {{
      :enable_32_bit           => true,
      :managed_runtime_version => 'v2.0',
      :managed_pipeline_mode   => 'Classic',
      :apppool_identitytype    => 'SpecificUser',
      :apppool_username		   => 'username',
      :apppool_userpw		   => 'password'
    }}

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v2.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v2.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 true",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'true\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 1",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Classic') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username').with(
      :command => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;\$pool.processModel.username = \"username\";\$pool.processModel.password = \"password\";\$pool.processModel.identityType = 3;\$pool | set-item;",
      :unless  => "Import-Module WebAdministration;\$iis = New-Object Microsoft.Web.Administration.ServerManager;iis:;\$pool = get-item IIS:\\AppPools\\myAppPool.example.com;if(\$pool.processModel.identityType -ne \"SpecificUser\"){exit 1;}\
if(\$pool.processModel.userName -ne username){exit 1;}if(\$pool.processModel.password -ne password){exit 1;}exit 0;",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }
  end

  describe 'when managing the iis application pool without passing parameters' do
    let(:title) { 'myAppPool.example.com' }

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 false",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'false\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Integrated') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }
    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end

  describe 'when managing the iis application with a managed_runtime_version of v2.0' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :managed_runtime_version => 'v2.0' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to_not raise_error }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v2.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v2.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }
  end

  describe 'when managing the iis application with a managed_runtime_version of v4.0' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :managed_runtime_version => 'v4.0' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to_not raise_error }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }
  end

  describe 'when managing the iis application with invalid managed_runtime_version parameter' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :managed_runtime_version => 'v9.0' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /"v9.0" does not match [^(v2\\.0\|v4\\.0)$]"/) }
  end

  describe 'when managing the iis application with invalid managed_runtime_version parameter' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :managed_runtime_version => 'v400' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /"v400" does not match [^(v2\\.0\|v4\\.0)$]"/) }
  end

  describe 'when managing the iis application and enable_32_bit is not a boolean value' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :enable_32_bit => 'false' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /"false" is not a boolean\./) }
  end

  describe 'when managing the iis application and identity type invalid' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :apppool_identitytype => '5' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /identitytype must be one of \'0\', \'1\',\'2\',\'3\',\'4\',\'LocalSystem\',\'LocalService\',\'NetworkService\',\'SpecificUser\',\'ApplicationPoolIdentity\'/) }
  end

  describe 'when managing the iis application and identity SpecificUser and no username supplied' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :apppool_identitytype => '3', :apppool_userpw => 'password' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /attempt set app pool identity to SpecificUser null or zero length \$apppool_username param/) }
  end

  describe 'when managing the iis application and identity SpecificUser and no password supplied' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :apppool_identitytype => '3', :apppool_username => 'username' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /attempt set app pool identity to SpecificUser null or zero length \$apppool_userpw param/) }
  end

  describe 'when managing the iis application and identity SpecificUser and no username or password supplied' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :apppool_identitytype => '3' } }

    it { expect { should contain_exec('Create-myAppPool.example.com') }.to raise_error(Puppet::Error, /attempt set app pool identity to SpecificUser null or zero length \$apppool_username param/) }
  end

  describe 'when managing the iis application pool and setting ensure to present' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :ensure => 'present' } }

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 false",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'false\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }
  end

  describe 'when managing the iis application pool and setting ensure to installed' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :ensure => 'installed' } }

    it { should contain_exec('Create-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; New-Item \"IIS:\\AppPools\\myAppPool.example.com\"",
      :onlyif  => "Import-Module WebAdministration; if((Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should contain_exec('Framework-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion v4.0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedRuntimeVersion).Value.CompareTo(\'v4.0\') -eq 0) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('32bit-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64 false",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" enable32BitAppOnWin64).Value -eq [System.Convert]::ToBoolean(\'false\')) { exit 1 } else { exit 0 }",
      :require => 'Exec[Create-myAppPool.example.com]',)
    }

    it { should contain_exec('ManagedPipelineMode-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Set-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode 0",
      :onlyif  => "Import-Module WebAdministration; if((Get-ItemProperty \"IIS:\\AppPools\\myAppPool.example.com\" managedPipelineMode).CompareTo('Integrated') -eq 0) { exit 1 } else { exit 0 }",)
    }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end

  describe 'when managing the iis application pool and setting ensure to absent' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :ensure => 'absent' } }

    it { should contain_exec('Delete-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Remove-Item \"IIS:\\AppPools\\myAppPool.example.com\" -Recurse",
      :onlyif  => "Import-Module WebAdministration; if(!(Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should_not contain_exec('Framework-myAppPool.example.com') }

    it { should_not contain_exec('32bit-myAppPool.example.com') }

    it { should_not contain_exec('ManagedPipelineMode-myAppPool.example.com') }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end

  describe 'when managing the iis application pool and setting ensure to purged' do
    let(:title) { 'myAppPool.example.com' }
    let(:params) { { :ensure => 'purged' } }

    it { should contain_exec('Delete-myAppPool.example.com').with(
      :command => "Import-Module WebAdministration; Remove-Item \"IIS:\\AppPools\\myAppPool.example.com\" -Recurse",
      :onlyif  => "Import-Module WebAdministration; if(!(Test-Path \"IIS:\\AppPools\\myAppPool.example.com\")) { exit 1 } else { exit 0 }",)
    }

    it { should_not contain_exec('Framework-myAppPool.example.com') }

    it { should_not contain_exec('32bit-myAppPool.example.com') }

    it { should_not contain_exec('ManagedPipelineMode-myAppPool.example.com') }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - ApplicationPoolIdentity') }

    it { should_not contain_exec('app pool identitytype - myAppPool.example.com - SPECIFICUSER - username') }
  end
end
