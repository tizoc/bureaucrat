require 'spec_helper'
require 'bureaucrat/widgets/time_slot'

describe Bureaucrat::Widgets::TimeSlotWidget do
  def widget
    described_class.new
  end

  let (:uncleaned_data) {{
    early_morning: {
      monday: true,
      tuesday: true
    },
    late_morning: {
      tuesday: true
    }
  }}

  let (:cleaned_data) {{
    early_morning: [:monday, :tuesday],
    late_morning: [:tuesday]
  }}

  it 'does nothing to data that has not been cleaned yet' do
    widget.normalize_for_view(uncleaned_data).should == uncleaned_data
  end

  it 'converts cleaned data' do
    widget.normalize_for_view(cleaned_data).should == uncleaned_data
  end
end
