SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/vendor/'
  add_filter '/sample_app/'
  add_filter '/lib/generators/vibe_errors/install/templates/'
  add_filter 'vibe_errors.gemspec'
  
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Helpers', 'app/helpers'
  add_group 'Views', 'app/views'
  add_group 'Lib', 'lib'
  add_group 'Config', 'config'
  add_group 'Generators', 'lib/generators'
  add_group 'Tasks', 'lib/tasks'
  
  minimum_coverage 95
  minimum_coverage_by_file 80
  refuse_coverage_drop
  
  # Generate multiple output formats
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter,
    SimpleCov::Formatter::LcovFormatter,
    SimpleCov::Formatter::SimpleFormatter
  ])
  
  # Track individual branches for more detailed coverage
  enable_coverage :branch
  primary_coverage :branch
  
  # Merge results from multiple test runs
  merge_timeout 3600
  
  # Custom coverage thresholds for different file types
  coverage_dir 'coverage'
  
  at_exit do
    SimpleCov.result.format!
    
    # Custom coverage reporting
    puts "\n=== Coverage Report ==="
    puts "Total Coverage: #{SimpleCov.result.covered_percent.round(2)}%"
    puts "Lines Covered: #{SimpleCov.result.covered_lines}/#{SimpleCov.result.total_lines}"
    puts "Branch Coverage: #{SimpleCov.result.branch_coverage_percent.round(2)}%"
    puts "Branches Covered: #{SimpleCov.result.covered_branches}/#{SimpleCov.result.total_branches}"
    
    # Check if coverage meets minimum requirements
    if SimpleCov.result.covered_percent < 95
      puts "\n❌ Coverage is below minimum threshold (95%)"
      exit 1
    else
      puts "\n✅ Coverage meets minimum requirements"
    end
  end
end