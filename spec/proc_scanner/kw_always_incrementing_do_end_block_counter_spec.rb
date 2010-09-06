require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Keyword always incrementing do..end block counter (by 1)" do

  behaves_like 'has started do...end counter'

  %w{class def module begin case module if unless}.each do |kw|

    should "increment counter with ... (#{kw} ...)" do
      do_end_counter(<<EOL
aa (#{kw} bb ... )
cc
EOL
             ).should.equal([1,1])
    end

    should "increment counter with ... ; #{kw} ..." do
      do_end_counter(<<EOL
aa; #{kw} bb ...
cc
EOL
             ).should.equal([1,1])
    end

    should "increment counter with ... \\n #{kw} ..." do
      do_end_counter(<<EOL
aa
#{kw} bb ...
cc
EOL
             ).should.equal([1,1])
    end

    should "increment counter with ... do #{kw} ..." do
      do_end_counter(<<EOL
aa do #{kw} bb ...
cc
EOL
             ).should.equal([1,1])
    end

    should "increment counter with ... then #{kw} ..." do
      do_end_counter(<<EOL
aa then #{kw} bb ...
cc
EOL
             ).should.equal([1,1])
    end

  end

end
