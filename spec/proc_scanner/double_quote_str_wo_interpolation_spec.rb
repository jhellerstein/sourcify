require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Double quote strings (wo interpolation)' do

  #%w{~ ` ! @ # $ % ^ & * _ - + = | \\ ; : ' " , . ? /}.map{|w| [w,w] }.concat(
  %w{~ ` ! @ # $ % ^ & * _ - + = | ; : ' " , . ? /}.map{|w| [w,w] }.concat(
    [%w{( )}, %w{[ ]}, %w({ }), %w{< >}]
  ).each do |q1,q2|
    ['Q', 'W', 'x', 'r', ''].each do |t|

      should "handle %#{t}#{q1}...#{q2} (wo escape (single))" do
        process(" xx %#{t}#{q1}hello#{q2} ").should.include("%#{t}#{q1}hello#{q2}")
      end

      should "handle %#{t}#{q1}...#{q2} (wo escape (multiple))" do
        tokens = process(" xx  %#{t}#{q1}hello#{q2} %#{t}#{q1}world#{q2}  ")
        tokens.should.include("%#{t}#{q1}hello#{q2}")
        tokens.should.include("%#{t}#{q1}world#{q2}")
      end

      should "handle %#{t}#{q1}...#{q2} (w escape (single))" do
        process(" xx %#{t}#{q1}hel\\#{q2}lo#{q2} ").should.include("%#{t}#{q1}hel\\#{q2}lo#{q2}")
      end

      should "handle %#{t}#{q1}...#{q2} (w escape (multiple))" do
        process(" xx %#{t}#{q1}h\\#{q2}el\\#{q2}lo#{q2} ").should.include("%#{t}#{q1}h\\#{q2}el\\#{q2}lo#{q2}")
      end

    end
  end

  %w{" / `}.each do |q|

    should "handle #{q}...#{q} (wo escape (single))" do
      process(%Q( xx #{q}hello#{q} )).should.include(%Q(#{q}hello#{q}))
    end

    should "handle #{q}...#{q} (wo escape & multiple)" do
      tokens = process(%Q( xx #{q}hello#{q} #{q}world#{q} ))
      tokens.should.include(%Q(#{q}hello#{q}))
      tokens.should.include(%Q(#{q}world#{q}))
    end

    should "handle #{q}...#{q} (w escape (single))" do
      process(%Q( xx #{q}hel\\#{q}lo#{q} )).should.include(%Q(#{q}hel\\#{q}lo#{q}))
    end

    should "handle #{q}...#{q} (w escape (multiple))" do
      process(%Q( xx #{q}h\\#{q}el\\#{q}lo#{q} )).should.include(%Q(#{q}h\\#{q}el\\#{q}lo#{q}))
    end

  end

end
