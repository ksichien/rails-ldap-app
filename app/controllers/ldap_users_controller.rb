class LdapUsersController < ApplicationController
  def add
    @ldap_user = LdapUser.new
  end

  def add_groups
    @ldap_user = LdapUser.new(ldap_user_params)
    if @ldap_user.valid?
      @result = @ldap_user.add_groups(@ldap_user.fname.downcase.strip,
                                      @ldap_user.lname.downcase.strip,
                                      @ldap_user.groups.downcase,
                                      retrieve_ldap_username,
                                      @ldap_user.ldap_password)
      render 'shared/result'
    else
      render 'add'
    end
  end

  def copy
    @ldap_user = LdapUser.new
  end

  def copy_groups
    @ldap_user = LdapUser.new(ldap_group_params)
    if @ldap_user.valid?
      @result = @ldap_user.copy_groups(@ldap_user.source.downcase.strip,
                                       @ldap_user.target.downcase.strip,
                                       retrieve_ldap_username,
                                       @ldap_group.ldap_password)
      render 'shared/result'
    else
      render 'copy'
    end
  end

  def new
    @ldap_user = LdapUser.new
  end

  def create
    @ldap_user = LdapUser.new(ldap_user_params)
    if @ldap_user.valid?
      @result = @ldap_user.create_user(@ldap_user.fname.downcase.strip,
                                       @ldap_user.lname.downcase.strip,
                                       @ldap_user.groups.downcase,
                                       retrieve_ldap_username,
                                       @ldap_user.ldap_password)
      render 'shared/result'
    else
      render 'new'
    end
  end

  def delete
    @ldap_user = LdapUser.new
  end

  def destroy
    @ldap_user = LdapUser.new(ldap_user_params)
    if @ldap_user.valid?
      @result = @ldap_user.destroy_user(@ldap_user.fname.downcase.strip,
                                        @ldap_user.lname.downcase.strip,
                                        retrieve_ldap_username,
                                        @ldap_user.ldap_password)
      render 'shared/result'
    else
      render 'delete'
    end
  end

  def edit
    @ldap_user = LdapUser.new
  end

  def update
    @ldap_user = LdapUser.new(ldap_user_params)
    if @ldap_user.valid?
      @result = @ldap_user.update_user(@ldap_user.fname.downcase.strip,
                                       @ldap_user.lname.downcase.strip,
                                       retrieve_ldap_username,
                                       @ldap_user.ldap_password)
      render 'shared/result'
    else
      render 'edit'
    end
  end

  def remove
    @ldap_user = LdapUser.new
  end

  def remove_groups
    @ldap_user = LdapUser.new(ldap_user_params)
    if @ldap_user.valid?
      @result = @ldap_user.remove_groups(@ldap_user.fname.downcase.strip,
                                         @ldap_user.lname.downcase.strip,
                                         @ldap_user.groups.downcase,
                                         retrieve_ldap_username,
                                         @ldap_user.ldap_password)
      render 'shared/result'
    else
      render 'remove'
    end
  end

  private def ldap_user_params
    params.require(:ldap_user).permit(:fname,
                                      :lname,
                                      :groups,
                                      :ldap_password)
  end
end
