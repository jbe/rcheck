RCheck 'RCheck/VERSION' do
  semver_regex = /^(\d+\.\d+\.\d+)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$/
  assert semver_regex, :===, RCheck::VERSION
end
