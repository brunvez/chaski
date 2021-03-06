defmodule ChaskiWeb.Api.V1.SubscriptionControllerTest do
  use ChaskiWeb.ConnCase

  alias Chaski.ClientApplications
  alias Chaski.ClientApplications.Subscription

  @create_attrs %{
    delay: 42,
    endpoint: "some endpoint",
    name: "some name"
  }
  @update_attrs %{
    delay: 43,
    endpoint: "some updated endpoint",
    name: "some updated name"
  }
  @invalid_attrs %{delay: nil, endpoint: nil, name: nil}

  def fixture(:subscription) do
    {:ok, subscription} = ClientApplications.create_subscription(@create_attrs)
    subscription
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all subscriptions", %{conn: conn} do
      conn = get(conn, Routes.api_v1_subscription_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create subscription" do
    test "renders subscription when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.api_v1_subscription_path(conn, :create), subscription: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.api_v1_subscription_path(conn, :show, id))

      assert %{
               "id" => id,
               "delay" => 42,
               "endpoint" => "some endpoint",
               "name" => "some name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.api_v1_subscription_path(conn, :create), subscription: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update subscription" do
    setup [:create_subscription]

    test "renders subscription when data is valid", %{
      conn: conn,
      subscription: %Subscription{id: id} = subscription
    } do
      conn =
        put(conn, Routes.api_v1_subscription_path(conn, :update, subscription),
          subscription: @update_attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.api_v1_subscription_path(conn, :show, id))

      assert %{
               "id" => id,
               "delay" => 43,
               "endpoint" => "some updated endpoint",
               "name" => "some updated name"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, subscription: subscription} do
      conn =
        put(conn, Routes.api_v1_subscription_path(conn, :update, subscription),
          subscription: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete subscription" do
    setup [:create_subscription]

    test "deletes chosen subscription", %{conn: conn, subscription: subscription} do
      conn = delete(conn, Routes.api_v1_subscription_path(conn, :delete, subscription))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.api_v1_subscription_path(conn, :show, subscription))
      end
    end
  end

  defp create_subscription(_) do
    subscription = fixture(:subscription)
    {:ok, subscription: subscription}
  end
end
