class LdapUsersController < ApplicationController

  def add
    @ldapuser = LdapUser.new
  end

  def add_list
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.add_list(@ldapuser.fname, @ldapuser.lname, @ldapuser.dn)
      render 'result'
    else
      render 'add'
    end
  end

  def new
    @ldapuser = LdapUser.new
  end

  def create
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.create(@ldapuser.fname, @ldapuser.lname, @ldapuser.dn)
      render 'result'
    else
      render 'new'
    end
  end

  def delete
    @ldapuser = LdapUser.new
  end

  def destroy
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.destroy(@ldapuser.fname, @ldapuser.lname)
      render 'result'
    else
      render 'delete'
    end
  end

  def edit
    @ldapuser = LdapUser.new
  end

  def update
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.update(@ldapuser.fname, @ldapuser.lname)
      render 'result'
    else
      render 'edit'
    end
  end

  def remove
    @ldapuser = LdapUser.new
  end

  def remove_list
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.remove_list(@ldapuser.fname, @ldapuser.lname, @ldapuser.dn)
      render 'result'
    else
      render 'remove'
    end
  end

  def search
    @ldapuser = LdapUser.new
  end

  def search_result
    @ldapuser = LdapUser.new(ldap_user_params)
    if @ldapuser.valid?
      @result = @ldapuser.search(@ldapuser.fname, @ldapuser.lname)
      render 'result'
    else
      render 'search'
    end
  end

private

  def ldap_user_params
    params.require(:ldap_user).permit(:fname, :lname, :dn)
  end

end
