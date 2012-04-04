module Bureaucrat
  module Formsets
    TOTAL_FORM_COUNT = :'TOTAL_FORMS'
    INITIAL_FORM_COUNT = :'INITIAL_FORMS'
    MAX_NUM_FORM_COUNT = :'MAX_NUM_FORMS'
    ORDERING_FIELD_NAME = :'ORDER'
    DELETION_FIELD_NAME = :'DELETE'

    class ManagementForm < Forms::Form
      include Fields
      include Widgets

      field TOTAL_FORM_COUNT, IntegerField.new(widget: HiddenInput)
      field INITIAL_FORM_COUNT, IntegerField.new(widget: HiddenInput)
      field MAX_NUM_FORM_COUNT, IntegerField.new(widget: HiddenInput,
                                                 required: false)
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
        @data = data || {}
        @initial = options[:initial]
        @error_class = options.fetch(:error_class, ErrorList)
        @errors = nil
        @non_form_errors = nil

        construct_forms
      end

      def each(&block)
        forms.each(&block)
      end

      def [](index)
        forms[index]
      end

      def length
        forms.length
      end

      def management_form
        if @is_bound
          form = ManagementForm.new(@data, auto_id: @auto_id,
                                    prefix: @prefix)
          unless form.valid?
            msg = 'ManagementForm data is missing or has been tampered with'
            raise ValidationError.new(msg)
          end
        else
          form = ManagementForm.new(nil, auto_id: @auto_id,
                                    prefix: @prefix,
                                    initial: {
                                      TOTAL_FORM_COUNT => total_form_count,
                                      INITIAL_FORM_COUNT => initial_form_count,
                                      MAX_NUM_FORM_COUNT => self.max_num
                                    })
        end
        form
      end

      def total_form_count
        if @is_bound
          management_form.cleaned_data[TOTAL_FORM_COUNT]
        else
          initial_forms = initial_form_count
          total_forms = initial_form_count + self.extra

          # Allow all existing related objects/inlines to be displayed,
          # but don't allow extra beyond max_num.
          if self.max_num > 0 && initial_forms > self.max_num
            initial_forms
          elsif self.max_num > 0 && total_forms > self.max_num
            max_num
          else
            total_forms
          end
        end
      end

      def initial_form_count
        if @is_bound
          management_form.cleaned_data[INITIAL_FORM_COUNT]
        else
          n = @initial ? @initial.length : 0

          (self.max_num > 0 && n > self.max_num) ? self.max_num : n
        end
      end

      def construct_forms
        @forms = (0...total_form_count).map { |i| construct_form(i) }
      end

      def construct_form(i, options={})
        defaults = {auto_id: @auto_id, prefix: add_prefix(i)}
        defaults[:initial] = @initial[i] if @initial && @initial[i]

        # Allow extra forms to be empty.
        defaults[:empty_permitted] = true if i >= initial_form_count
        defaults.merge!(options)
        form_data = @is_bound ? @data : nil
        form = self.form.new(form_data, defaults)
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

            if i >= initial_form_count && !form.changed?
              false
            else
              should_delete_form?(form)
            end
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
            next if self.can_delete && should_delete_form?(form)
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

      def should_delete_form?(form)
        field = form.fields[DELETION_FIELD_NAME]
        raw_value = form.send(:raw_value, DELETION_FIELD_NAME)
        field.clean(raw_value)
      end

      def valid?
        return false unless @is_bound

        forms_valid = true

        (0...total_form_count).each do |i|
          form = @forms[i]
          next if self.can_delete && should_delete_form?(form)

          forms_valid = false unless errors[i].empty?
        end

        forms_valid && non_form_errors.empty?
      end

      def full_clean
        if @is_bound
          @errors = @forms.collect(&:errors)

          begin
            self.clean
          rescue ValidationError => e
            @non_form_errors = @error_class.new(e.messages)
          end
        else
          @errors = []
        end
      end

      def clean
      end

      def add_fields(form, index)
        if can_order
          attrs = {label: 'Order', required: false}
          attrs[:initial] = index + 1 if index && index < initial_form_count
          form.fields[ORDERING_FIELD_NAME] = IntegerField.new(attrs)
        end
        if can_delete
          field = BooleanField.new(label: 'Delete', required: false)
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
