class UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy ]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy!
  end

  def add_product_to_shopping_cart
    carts = Faraday.new(
      url: 'http://localhost:3002',
      headers: {'Content-Type' => 'application/json'}
    )

    response = carts.post('/add_to_cart') do |req|
      req.body = { user_id: params[:user_id], product_id: params[:product_id] }.to_json
    end
  end

  def shopping_cart
    carts = Faraday.new(
      url: 'http://localhost:3002',
      headers: {'Content-Type' => 'application/json'}
    )

    cart_response = carts.get('/current_user_shopping_cart', { user_id: params[:id] } )

    products = Faraday.new(
      url: 'http://localhost:3001',
      headers: {'Content-Type' => 'application/json'}
    )
    
    response = JSON.parse(cart_response.body).map do |product_id|
      JSON.parse(products.get("/products/#{product_id}").body)
    end
  
    render json: response
  end

  def clean_cart
    carts = Faraday.new(
      url: 'http://localhost:3002',
      headers: {'Content-Type' => 'application/json'}
    )

    cart_response = carts.delete('/delete_current_user_cart', { user_id: params[:id] } )

    render json: cart_response.body
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:name, :email)
    end
end
