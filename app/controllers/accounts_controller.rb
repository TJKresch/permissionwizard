class AccountsController < ApplicationController
  # GET /accounts
  # GET /accounts.json
  def index
    @accounts = Account.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.json
  def show
    @account = Account.find(params[:id])
    @templates = @account.templates
    @defaults = Template.where(is_default: true).order(:id)
    @differences = Template.differences(@templates, @defaults)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.json
  def new
    @account = Account.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @account = Account.find(params[:id])
    @templates = @account.templates
  end

  # POST /accounts
  # POST /accounts.json
  def create
    @account = Account.new(account_params)

    respond_to do |format|
      if @account.save
        Account.copy_templates(1, @account.id)
        format.html { redirect_to new_account_template_path(@account), notice: 'Account was successfully created.' }
        format.json { render json: @account, status: :created, location: @account }
      else
        flash[:error] = @account.errors.empty? ? "Error" : @account.errors.full_messages.to_sentence
        format.html { render action: "new" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.json
  def update
    @account = Account.find(params[:id])

    respond_to do |format|
      if @account.update_attributes(account_params)
        format.html { redirect_to @account, notice: 'Account was successfully updated.' }
        format.json { head :no_content }
      else
        flash[:error] = @account.errors.empty? ? "Error" : @account.errors.full_messages.to_sentence
        format.html { render action: "edit" }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.json
  def destroy
    @account = Account.find(params[:id])
    @account.destroy

    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.json { head :no_content }
    end
  end

  def duplicate_templates
    @account = Account.find(params[:id])
    @new_account = @account.dup
    @new_account.save!
    Account.copy_templates(@account.id, @new_account.id)
    redirect_to edit_account_path(@new_account)
  end

  private

  def account_params
    params.require(:account).permit(:name, :admin_id)
  end

end
