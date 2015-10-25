module AccountName
  def account_name
    account && account.name
  end

  def account_name= name
    self.account = Account.find_by(name: name)
  end
end
