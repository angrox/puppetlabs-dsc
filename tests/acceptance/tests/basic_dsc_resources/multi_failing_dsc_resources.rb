require 'dsc_utils'
test_name 'FM-2624 - C87654 - Apply DSC Resource Manifest with Multiple Failing DSC Resources'

confine(:to, :platform => 'windows')

# In-line Manifest
test_dir_bad = "Q:/not/here"

dsc_manifest = <<-MANIFEST
dsc_file {'bad_test_dir_1':
  dsc_ensure          => 'present',
  dsc_type            => 'Directory',
  dsc_destinationpath => '#{test_dir_bad}_1'
}
dsc_file {'bad_test_dir_2':
  dsc_ensure          => 'present',
  dsc_type            => 'Directory',
  dsc_destinationpath => '#{test_dir_bad}_2'
}
MANIFEST

# Verify
error_msg = /Error:/

# Tests
agents.each do |agent|
  step 'Apply Manifest'
  on(agent, puppet('apply'), :stdin => dsc_manifest, :acceptable_exit_codes => 0) do |result|
    expect_failure('Expected to fail because of MODULES-2194') do
      assert_no_match(error_msg, result.stderr, 'Expected error was not detected!')
    end
  end
end