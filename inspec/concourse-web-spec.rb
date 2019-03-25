describe file('/usr/local/concourse/keys/authorized_worker_keys') do
  it { should exist }
end

describe file('/usr/local/concourse/keys/session_signing_key') do
  it { should exist }
end

describe file('/usr/local/concourse/keys/tsa_host_key') do
  it { should exist }
end

describe file('/usr/local/concourse/keys/worker_key') do
  it { should exist }
end

describe file('/lib/systemd/system/concourse-web.service') do
  it { should exist }
end

describe systemd_service('concourse-web') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe user('concourse') do
  it { should exist }
end

describe port(8080) do
  it { should be_listening }
end