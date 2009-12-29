module AuthorizedSystem
  def self.included(base)
    base.send :class_inheritable_array, :auth_requirements
    base.send :include, AuthorizationSecurityInstanceMethods
    base.send :extend, AuthorizationSecurityClassMethods
    base.send :helper_method, :url_options_authenticate? 
    base.send :helper_method, :next_authorized_url? 
    
    base.send :auth_requirements=, []
    
  end

  module AuthorizationSecurityClassMethods
        
    # This is the core of AuthorizedSystem
    #
    # By calling require_authorization at the top of your
    # controller via dynamically create methods, you can
    # test for a variety of conditions.
    #
    # Example Usage:
    # 
    #   authorize_role :contractor
    #   authorize_role :admin, :only => :destroy # don't allow contractors to destroy
    #   
    #   authorize_state :active, :only => [:new, :create] # only allow active users to create new items
    # 
    #   Vestal Modification- allow chaining of roles to permit OR and AND
    #   
    #   Example Usage:
    #     
    #   ORing
    #
    #   authorize_role [ :contractor, :manager ] # allow :contractor OR :manager roles
    #
    #   =========================================================================
    #  
    #   ANDing
    #
    #   authorize_role [ :manager ] 
    #   authorize_role [ :big_boss ] #allow a user which only has roles :manager AND :big_boss
    #
    # Valid options
    #
    #   * :only               - authorization is only required for these actions
    #   * :only_if_logged_in? - authorization is only required for these actions if the user is logged_in?
    #   * :except             - authorization is required for all other actions
    #   * :if                 - a Proc or a string to evaluate; the authorization is required if it returns true
    #   * :unless             - the inverse of :if
    #
    #   * :redirect_url - takes a named route as a symbol (:new_example_path), string "/example/new",
    #     or hash { :controller => "example", :action => "new" }
    #
    #   The user is redirected to :redirect_url if authorization fails. If nothing is specified, it defaults
    #   to restful_authentication's access_denied
    #
    #   * :render_url - takes a hash of parameters to pass to render such as
    #     { :file => "#{RAILS_ROOT}/public/404.html" }
    #
    #   * :status - takes a status code ("304", "404", "500") as a string
    #
    #   Rather than redirecting the user, the action specified in :render_url is rendered with the
    #   given status. If no :render_url is specified, it renders a blank page with the status code given.
    #        
    def require_authorization(type, values, options = {})
      options.assert_valid_keys(:if, :unless, :only, :only_if_logged_in?, :except, :redirect_url, :render_url, :status)
      
      # only declare the before filter once
      unless @before_filter_declared ||= false
        @before_filter_declared = true
        before_filter :check_authorization
      end
      
      # convert values to an array if it isn't already one
      values = [values] unless Array === values
            
      # convert any keys into symbols
      for key in [:only, :except]
        if options.has_key?(key)
          options[key] = [options[key]] unless Array === options[key]
          options[key] = options[key].compact.collect{|v| v.to_sym}
        end 
      end
      
      self.auth_requirements||=Array.new()
      
      # If the values match an existing Array of values (or Symbol), we update the existing values
      # instead of appending another set of values. 
      overwrite_existing_requirement = false
      # Iterate through the existing requirements
      self.auth_requirements.each_index do |index|
        requirement =  self.auth_requirements[index]
        if type == requirement[:type] # Is this requirement the same type (ie, role?)
        existing_values = requirement[:values]
       if Array === existing_values && Array === values # Are both values Arrays?
         # Compare if the contents are equal, ignoring order
          overwrite_existing_requirement = (Set.new(existing_values) == Set.new(values))
          Rails.logger.info(overwrite_existing_requirement)
        else Symbol === existing_values && Symbol === values
          overwrite_existing_requirement = (values == existing_values)
        end
        # If we find the values to be the same, update the existing options
        if overwrite_existing_requirement
          requirement[:options] = options
          self.auth_requirements[index] = requirement
          break
        end
        end
      end
      
      # Did we overwrite an existing requirement? If not, just append it to the array of reqs
      unless overwrite_existing_requirement
      self.auth_requirements << {:type => type, :values => values, :options => options }
    end
    end
      
    # The method_missing helper for AuthorizedSystem catches
    # all class level methods beginning with authorize_foo
    # that have a matching foo_is_authorized? method.
    #
    # It then executes request_authorization and passes
    # foo as the authorization type.    
    def method_missing(method_id, *arguments)
      super unless method_id.to_s.match(/^authorize_([_a-zA-Z]\w*)$/) and respond_to?("#{method_id.to_s.gsub(/^authorize_/,'')}_is_authorized?")
      require_authorization(method_id.to_s.gsub(/^authorize_/,''), *arguments )      
    end

    # This method takes a user, params (which includes a :controller
    # and :action) and a binding. It evalutes all authorization
    # requirements for this particular route and returns the 
    # :redirect_url and :status for the first requirement it fails
    # to meet.    
    def next_authorized_url_for?(user, params = {}, binding = self.binding)
      return nil unless Array===self.auth_requirements
      self.auth_requirements.each do |requirement|
        type = requirement[:type]        
        values = requirement[:values]
        options = requirement[:options]
        # handle the restriction keys associated with this requirement
        if options.has_key?(:only_if_logged_in?)
          next unless (options[:only_if_logged_in?].include?( (params[:action]||"index").to_sym) and user)
        end

        if options.has_key?(:only)
          next unless options[:only].include?( (params[:action]||"index").to_sym)
        end
    
        if options.has_key?(:except)
          next if options[:except].include?( (params[:action]||"index").to_sym)
        end
    
        if options.has_key?(:if)
          next unless ( String===options[:if] ? eval(options[:if], binding) : options[:if].call(params) )
        end
    
        if options.has_key?(:unless)
          next if ( String===options[:unless] ? eval(options[:unless], binding) : options[:unless].call(params) )
        end
        
        if options.has_key?(:render_url) && options.has_key?(:status)
          options[:redirect_url] = options[:render_url]
        end
    
        # run the authorization test method associated with the current requirement
        
       # Change this block over to a strict AND operation to an OR operation
       # IE, check if a user has role :tenant || :manager instead of check if user has roles :tenant && :manager
       # Original Code in values.each block: return { :url => options[:redirect_url], :status => options[:status] } unless user and send("#{type}_is_authorized?", user, value)
        approved_role_found = false
        values.each { |value|
          if send("#{type}_is_authorized?", user, value)
            approved_role_found = true
            break
          end
        } unless (user.nil? || user==:false || user==false)  
        unless approved_role_found
          return { :url => options[:redirect_url], :status => options[:status] }
        end
      end
    
      return nil
    end


    # This is a wrapper method for next_authorized_url_for? that makes
    # up the core of AuthorizedSystem. If next_authorized_url_for?
    # returns nil, the user is authorized to view the current page.
    def user_authorized_for?(user, params = {}, binding = self.binding)
      unless next_authorized_url_for?(user, params, binding)
        return true
      end
    
      return false
    end
  
    def reset_auth_requirements!
      self.auth_requirements.clear
    end


    # == Authorization Test Methods
    #
    # These methods correspond to types stored in auth_requirement.
    #
    # For a particular form of authorization to exist, it must have
    # a method here in the format #{type}_is_authorized?(user, value)
    # that returns a boolean value
    #
    # next_authorized_url_for? will dynamically allow for new
    # authorization requirements based on these methods. In other words,
    # if the following method existed:
    #
    #   def foo_is_authorized?(user, value)
    #     true
    #   end
    #
    # the dynamic method authorize_foo would be available in your
    # controllers.
  
    # This method invokes the generated has_role? method to
    # determine if a user has a given role. By default,
    # has_role? downcases both the stored roles and the
    # requested match, so Admin == admin == ADMIN and so on.
    def role_is_authorized?(user, value)
      user.has_role?(value)
    end

    # This method is provided as an example of authorization beyond
    # the internal role system. It verifies that the user has
    # a field "state" that matches the required value. This works
    # out of the box with Scott Barron's acts_as_state_machine.
    def state_is_authorized?(user, value)
      user.state.downcase == value.downcase
    end
  
  end

    module AuthorizationSecurityInstanceMethods
      # Verifies that restful_authentication is properly required before restful-authorization gets going
      def self.included(base)
        raise "Because restful-authorization extends restful_authentication, AuthenticatedSystem must be included before first before AuthorizedSystem!" unless base.included_modules.include?(AuthenticatedSystem)
      end 

      # When user_authorized_for fails, authorization_denied stores the current location
      # in the session and then handles :redirect_to and :status as described in
      # the require_authorization documentation.
      #
      # It's important to use restful_authentication's redirect_back_or_default
      # instead of redirect_to to make sure that the workflow can move forward
      # as well as backward.
      def authorization_denied
        store_location
        next_url = self.next_authorized_url?(params)
        if status = next_url[:status]
          if next_url[:url]
            render next_url[:url].merge(:status => status)
          else
            render :nothing => true, :status => status
          end
        else
          if next_url[:url]        
            redirect_to(Symbol===next_url[:url] ? eval(next_url[:url].to_s) : next_url[:url])
          else
            access_denied
          end
        end      
      end

      # This is the before filter called by require_authorization
      def check_authorization    
        return authorization_denied unless self.url_options_authenticate?(params)
        true
      end

    protected
      # This calls user_authorized_for? on the given parameters. If no controller
      # is specified, it defaults to the current one.
      def url_options_authenticate?(params = {})
        params = params.symbolize_keys
        if params[:controller]
          base = eval("#{params[:controller]}_controller".classify)
        else
          base = self.class
        end
        base.user_authorized_for?(current_user, params, binding)
      end

      # This calls next_authorized_url_for? on the given parameters. If no controller
      # is specified, it defaults to the current one.
      def next_authorized_url?(params = {})
        params = params.symbolize_keys
        if params[:controller]
          base = eval("#{params[:controller]}_controller".classify)
        else
          base = self.class
        end
        base.next_authorized_url_for?(current_user, params, binding)
      end

    end
  end