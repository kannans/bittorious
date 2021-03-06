require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  include Devise::Test::ControllerHelpers
  include Warden::Test::Helpers


  GOOD = { name: :good }

  setup do
    @unapproved = users(:unapproved)
    @unassigned = users(:unassigned)
    @subscriber = users(:subscriber)
    @publisher = users(:publisher)
    @admin = users(:admin)
  end


  def user_show_check(type)
  	log_in type
  	get :show, params: { id: @unapproved }, format: :json
  	assert_response :redirect
  	get :show, params: { id: @unassigned }, format: :json
  	assert_response :redirect
  	get :show, params: { id: @subscriber }, format: :json
  	assert_response :redirect
  	get :show, params: { id: @publisher }, format: :json
  	assert_response :redirect
  	get :show, params: { id: @admin }, format: :json
  	assert_response :redirect
  end

  test "should not allow account self-approval" do
    log_in :unapproved
    post :approve, params: { id: @unapproved, user: {approved: true} }, format: :json
    assert_response :unauthorized
  end

  test "should not allow account approvals as unassigned" do
  	log_in :unassigned
  	post :approve, params: { id: @unapproved }, format: :json
  	assert_response :redirect
  end

  test "should not allow account approvals as subscriber" do
  	log_in :subscriber
  	post :approve, params: { id: @unapproved }, format: :json
  	assert_response :redirect
  end

  test "should not allow account approvals as publisher" do
  	log_in :publisher
  	post :approve, params: { id: @unapproved }, format: :json
  	assert_response :redirect
  end

  test "should allow admin account approvals" do
  	log_in :admin
  	post :approve, params: { id: @unapproved }, format: :json
  	assert_response :success
  end

  test "should not allow non-admin account denials" do
  	post :deny, params: { id: @unapproved }, format: :json
  	assert_response :unauthorized

  	log_in :unassigned
  	post :deny, params: { id: @unapproved }, format: :json
  	assert_response :redirect

  	log_in :subscriber
  	post :deny, params: { id: @unapproved }, format: :json
  	assert_response :redirect

  	log_in :publisher
  	post :deny, params: { id: @unapproved }, format: :json
  	assert_response :redirect
  end

  test "should allow admin account denials" do
  	log_in :admin
  	post :deny, params: { id: @unapproved }, format: :json
  	assert_response :success
  end

  test 'should show user as admin' do
  	log_in :admin
  	get :show, params: { id: @unapproved }, format: :json
  	assert_response :success
  	get :show, params: { id: @unassigned }, format: :json
  	assert_response :success
  	get :show, params: { id: @subscriber }, format: :json
  	assert_response :success
  	get :show, params: { id: @publisher }, format: :json
  	assert_response :success
  	get :show, params: { id: @admin }, format: :json
  	assert_response :success
  end


  test 'should not show user as unassigned' do
  	user_show_check :unassigned
  end

  test 'should not show user as subscriber' do
  	user_show_check :subscriber
  end

  test 'should not show user as publisher' do
  	user_show_check :publisher
  end

  test 'should not render user index as unauthenticated' do
    get :index
    assert_response :redirect
    get :index, format: :json
    assert_response :unauthorized
  end

  test 'should not render user index as unassigned' do
    log_in :unassigned
    get :index, format: :json
    # assert_response :success
    # get :index
    assert_response :unauthorized
  end


  test 'should not render user index as subscriber' do
    log_in :subscriber
    get :index, format: :json
    # assert_response :success
    # get :index
    assert_response :unauthorized
  end


  test 'should not render user index as publisher' do
    log_in :publisher
    get :index, format: :json
    # assert_response :success
    # get :index
    assert_response :unauthorized
  end

  test 'should render index as admin' do
    log_in :admin
    get :index
    assert_response :success
  end

  test 'should not update different user as publisher' do
    log_in :publisher
    patch :update, params: {id: @subscriber, user: GOOD}, format: :json
    assert_response :redirect
    # assert assigns(:user)
  end

  test 'should update different user as admin' do
    log_in :admin
    patch :update, params: {id: @subscriber, user: GOOD}, format: :json
    assert_response :success
    # assert assigns(:user)
  end

end
