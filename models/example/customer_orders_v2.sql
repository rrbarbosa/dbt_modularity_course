-- TODO: translate names from stg_orders
-- TODO: check if all fields exist and match
select
    *,
    cummulative_amount_paid as customer_lifetime_value,
    first_order_date as fdos
from {{ ref('stg_orders') }} p
order by customer_id, order_id
