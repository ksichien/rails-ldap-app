class LdapGroupsController < ApplicationController
  def add
    @ldap_group = LdapGroup.new
  end

  def add_users
    @ldap_group = LdapGroup.new(ldap_group_params)
    if @ldap_group.valid?
      @result = @ldap_group.add_users(@ldap_group.name.downcase.strip,
                                      @ldap_group.users.downcase,
                                      retrieve_ldap_username,
                                      @ldap_group.ldap_password)
      render 'shared/result'
    else
      render 'add'
    end
  end

  def new
    @ldap_group = LdapGroup.new
  end

  def create
    @ldap_group = LdapGroup.new(ldap_group_params)
    if @ldap_group.valid?
      @result = @ldap_group.create(@ldap_group.name.downcase.strip,
                                   @ldap_group.users.downcase,
                                   retrieve_ldap_username,
                                   @ldap_group.ldap_password)
      render 'shared/result'
    else
      render 'new'
    end
  end

  def delete
    @ldap_group = LdapGroup.new
  end

  def destroy
    @ldap_group = LdapGroup.new(ldap_group_params)
    if @ldap_group.valid?
      @result = @ldap_group.destroy(@ldap_group.name.downcase.strip,
                                    retrieve_ldap_username,
                                    @ldap_group.ldap_password)
      render 'shared/result'
    else
      render 'delete'
    end
  end

  def remove
    @ldap_group = LdapGroup.new
  end

  def remove_users
    @ldap_group = LdapGroup.new(ldap_group_params)
    if @ldap_group.valid?
      @result = @ldap_group.remove_users(@ldap_group.name.downcase.strip,
                                         @ldap_group.users.downcase,
                                         retrieve_ldap_username,
                                         @ldap_group.ldap_password)
      render 'shared/result'
    else
      render 'remove'
    end
  end

  private def ldap_group_params
    params.require(:ldap_group).permit(:name, :users, :ldap_password)
  end
end
