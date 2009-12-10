# While we'd like ActiveRecord::Base#update_attribute to do the right thing,
# it doesn't: see
# http://javathehutt.blogspot.com/2007/04/rails-realities-part-25-do-what-you-say.html
#
# Despite its name, update_attribute will save ALL attributes in a record 
# which are not saved, in addition to the given one, but is documented to 
# not validate first. That's insanity.
#
# Rather than override this behavior (which could affect existing code in
# gems, etc), we'll introduce a new method that does what we intended:
# - change the attribute on the model object
# - write that attribute ONLY to the database
#
# We can watch for this to be fixed, but it seems unlikely given the 
# response to this ticket: http://dev.rubyonrails.org/ticket/8053

module ActiveRecord
  class Base 
    # Updates a single attribute without validation, writing through to
    # the database. Returns true to mimic update_attribute, which returns
    # the result of save().
    def update_single_attribute(name, value)
      name = name.to_s
      if send(name) == value
        # attribute already has this value. Do nothing if the database
        # already has it.
        return true unless send(name + "_changed?")
      else
        # set the value, but leave it non-dirty
        write_attribute(name, value)
        changed_attributes.delete(name)
      end

      # safely escape the value before we update
      atts = attributes_with_quotes(false)
      connection.update(
        "UPDATE #{self.class.table_name} " +
        "SET #{quoted_comma_pair_list(connection, {name => atts[name]})} " +
        "WHERE #{self.class.primary_key} = #{connection.quote(id)}",
        "#{self.class.name} Update"
      )
      return true
    end
  end
end
