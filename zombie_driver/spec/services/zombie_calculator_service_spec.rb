require 'rails_helper'

describe ZombieCalculatorService, type: :service do
  TEST_CASES = [
    {
      test_result: false,
      data: [ 
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30" },
        {"id"=>"5", "latitude"=>"79", "longitude"=>"32" },
        {"id"=>"5", "latitude"=>"82", "longitude"=>"37" }
      ]
    },

    {
      test_result: false,
      data: [ 
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30" },
        {"id"=>"5", "latitude"=>"73", "longitude"=>"21" }
      ]
    },

    {
      test_result: true,
      data: [ 
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30.32" },
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30.30" },
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30.30" }
      ]
    },

    {
      test_result: true,
      data: [ 
        {"id"=>"5", "latitude"=>"82", "longitude"=>"30" },
      ]
    },

    {
      test_result: true,
      data: []
    },

    {
      test_result: true,
      data: []
    }
  ]
  subject { ZombieCalculatorService }

  def action(data)
    subject.call(data)
  end
  
  TEST_CASES.each do |test_case|
    it { expect(action(test_case[:data])).to eq(test_case[:test_result])}
  end
end