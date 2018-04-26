class LdapSearchesController < ApplicationController
  def search
    @ldap_search = LdapSearch.new
  end

  def search_result
    @ldap_search = LdapSearch.new(ldap_search_params)
    if @ldap_search.valid?
      @result = @ldap_search.search(@ldap_search.name.downcase.strip,
                                    retrieve_ldap_username,
                                    @ldap_search.ldap_password)
      render 'shared/result'
    else
      render 'search'
    end
  end

  private def ldap_search_params
    params.require(:ldap_search).permit(:name, :ldap_password)
  end
end
