class LdapUsersController < ApplicationController

  def add
    @ldapuser = LdapUser.new
  end

  def add_group
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.add_group(@ldapuser.fname.downcase, @ldapuser.lname.downcase, @ldapuser.dn, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'add'
    end
  end

  def add_multiple
    @ldapuser = LdapUser.new
  end

  def add_group_multiple
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.add_group_multiple(@ldapuser.group_members, @ldapuser.group_name.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'add_multiple'
    end
  end

  def new
    @ldapuser = LdapUser.new
  end

  def create
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.create(@ldapuser.fname.downcase, @ldapuser.lname.downcase, @ldapuser.dn, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'new'
    end
  end

  def new_group
    @ldapuser = LdapUser.new
  end

  def create_group
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.create_group(@ldapuser.group_name, @ldapuser.group_members, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'new_group'
    end
  end

  def delete
    @ldapuser = LdapUser.new
  end

  def destroy
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.destroy(@ldapuser.fname.downcase, @ldapuser.lname.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'delete'
    end
  end

  def delete_group
    @ldapuser = LdapUser.new
  end

  def destroy_group
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.destroy_group(@ldapuser.group_name.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'delete_group'
    end
  end

  def edit
    @ldapuser = LdapUser.new
  end

  def update
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.update(@ldapuser.fname.downcase, @ldapuser.lname.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'edit'
    end
  end

  def remove
    @ldapuser = LdapUser.new
  end

  def remove_group
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.remove_group(@ldapuser.fname.downcase, @ldapuser.lname.downcase, @ldapuser.dn, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'remove'
    end
  end

  def remove_multiple
    @ldapuser = LdapUser.new
  end

  def remove_group_multiple
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.remove_group_multiple(@ldapuser.group_members, @ldapuser.group_name.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'remove_multiple'
    end
  end

  def search
    @ldapuser = LdapUser.new
  end

  def search_result
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.search(@ldapuser.group_name.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'search'
    end
  end

  def search_group
    @ldapuser = LdapUser.new
  end

  def search_group_result
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.search_group(@ldapuser.fname.downcase, @ldapuser.lname.downcase, retrieve_ldap_username, @ldapuser.password)
      render 'result'
    else
      render 'search'
    end
  end

private

  def ldap_user_params
    params.require(:ldap_user).permit(:fname, :lname, :dn, :group_name, :group_members, :password)
  end

end
