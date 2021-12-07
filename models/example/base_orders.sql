select 
    id as order_id,
    "user_id" as customer_id,
    order_date as order_placed_at,
    "status" as order_status
from {{ ref('jaffle_shop_orders') }}
