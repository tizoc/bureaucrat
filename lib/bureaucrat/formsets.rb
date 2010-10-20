module Bureaucrat
  module Formsets
    TOTAL_FORM_COUNT = :'TOTAL_FORMS'
    INITIAL_FORM_COUNT = :'INITIAL_FORMS'
    ORDERING_FIELD_NAME = :'ORDER'
    DELETION_FIELD_NAME = :'DELETE'

    class ManagementForm < Forms::Form
      include Fields
      include Widgets

      field TOTAL_FORM_COUNT, IntegerField.new(:widget => HiddenInput)
      field INITIAL_FORM_COUNT, IntegerField.new(:widget => HiddenInput)
    end

    class BaseFormSet
      include Utils
      include Fields
      include Forms

      def self.default_prefix
        'form'
      end

      attr_accessor :forms, :form, :extra, :can_order, :can_delete, :max_num

      def initialize(data=nil, options={})
        set_defaults
        @is_bound = !data.nil?
        @prefix = options.fetch(:prefix, self.class.default_prefix)
        @auto_id = options.fetch(:auto_id, 'id_%s')
        @data = data
        @files = options[:files]
        @initial = options[:initial]
        @error_class = options.fetch(:error_class, ErrorList)
        @errors = nil
        @non_form_errors = nil

        construct_forms
      end

      def to_s
        as_table
      end

      def management_form
        if @data || @files
          form = ManagementForm.new(@data, :auto_id => @auto_id,
                                    :prefix => @prefix)
          raise FieldValidationError.new('ManagementForm data is missing or has been tampered with') unless
            form.valid?
        else
          form = ManagementForm.new(nil, :auto_id => @auto_id,
                                    :prefix => @prefix,
                                    :initial => {
                                      TOTAL_FORM_COUNT => total_form_count,
                                      INITIAL_FORM_COUNT => initial_form_count
                                    })
        end
        form
      end

      def total_form_count
        if @data || @files
          management_form.cleaned_data[TOTAL_FORM_COUNT]
        else
          n = initial_form_count + self.extra
          (n > self.max_num && self.max_num > 0) ? self.max_num : n
        end
      end

      def initial_form_count
        if @data || @files
          management_form.cleaned_data[INITIAL_FORM_COUNT]
        else
          n = @initial ? @initial.length : 0
          (n > self.max_num && self.max_num > 0) ? self.max_num : n
        end
      end

      def construct_forms
        @forms = (0...total_form_count).map { |i| construct_form(i) }
      end

      def construct_form(i, options={})
        defaults = {:auto_id => @auto_id, :prefix => add_prefix(i)}
        defaults[:files] = @files if @files
        defaults[:initial] = @initial[i] if @initial && @initial[i]

        # Allow extra forms to be empty.
        defaults[:empty_permitted] = true if i >= initial_form_count
        defaults.merge!(options)
        form = self.form.new(@data, defaults)
        add_fields(form, i)
        form
      end

      def initial_forms
        @forms[0, initial_form_count]
      end

      def extra_forms
        n = initial_form_count
        @forms[n, @forms.length - n]
      end

      # Maybe this should just go away?
      def cleaned_data
        unless valid?
          raise NoMethodError.new("'#{self.class.name}' object has no method 'cleaned_data'")
        end
        @forms.collect(&:cleaned_data)
      end

      def deleted_forms
        unless valid? && self.can_delete
          raise NoMethodError.new("'#{self.class.name}' object has no method 'deleted_forms'")
        end

        if @deleted_form_indexes.nil?
          @deleted_form_indexes = (0...total_form_count).select do |i|
              form = @forms[i]
              (i < initial_form_count || form.changed?) && form.cleaned_data[DELETION_FIELD_NAME]
            end
        end
        @deleted_form_indexes.map {|i| @forms[i]}
      end

      def ordered_forms
        unless valid? && self.can_order
          raise NoMethodError.new("'#{self.class.name}' object has no method 'ordered_forms'")
        end

        if @ordering.nil?
          @ordering = (0...total_form_count).map do |i|
              form = @forms[i]
              next if i >= initial_form_count && !form.changed?
              next if self.can_delete && form.cleaned_data[DELETION_FIELD_NAME]
              [i, form.cleaned_data[ORDERING_FIELD_NAME]]
            end.compact
          @ordering.sort! do |a, b|
              if x[1].nil? then 1
              elsif y[1].nil? then -1
              else x[1] - y[1]
              end
            end
        end

        @ordering.map {|i| @forms[i.first]}
      end

      def non_form_errors
        @non_form_errors || @error_class.new
      end

      def errors
        full_clean if @errors.nil?
        @errors
      end

      def valid?
        return false unless @is_bound
        forms_valid = true
        (0...total_form_count).each do |i|
            form = @forms[i]
            if self.can_delete
              field = form.fields[DELETION_FIELD_NAME]
              raw_value = form.send(:raw_value, DELETION_FIELD_NAME)
              should_delete = field.clean(raw_value)
              next if should_delete
            end
            forms_valid = false unless errors[i].empty?
          end
        forms_valid && non_form_errors.empty?
      end

      def full_clean
        if @is_bound
          @errors = @forms.collect(&:errors)

          begin
            self.clean
          rescue FieldValidationError => e
            @non_form_errors = e.messages
          end
        else
          @errors = []
        end
      end

      def clean
      end

      def add_fields(form, index)
        if can_order
          attrs = {:label => 'Order', :required => false}
          attrs[:initial] = index + 1 if index < initial_form_count
          form.fields[ORDERING_FIELD_NAME] = IntegerField.new(attrs)
        end
        if can_delete
          field = BooleanField.new(:label => 'Delete', :required => false)
          form.fields[DELETION_FIELD_NAME] = field
        end
      end

      def add_prefix(index)
        '%s-%s' % [@prefix, index]
      end

      def multipart?
        @forms && @forms.first.multipart?
      end
    end

    module_function

    def make_formset_class(form, options={})
      formset = options.fetch(:formset, BaseFormSet)

      Class.new(formset) do
        define_method :set_defaults do
          @form = form
          @extra = options.fetch(:extra, 1)
          @can_order = options.fetch(:can_order, false)
          @can_delete = options.fetch(:can_delete, false)
          @max_num = options.fetch(:max_num, 0)
        end
        private :set_defaults
      end
    end

    def all_valid?(formsets)
      valid = true
      formsets.each do |formset|
          valid = false unless formset.valid?
        end
      valid
    end

  end
end
