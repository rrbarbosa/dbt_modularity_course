-- TODO: check if all fields exist and match
select
    *,
    cummulative_amount_paid as customer_lifetime_value,
    first_order_date as fdos
from {{ ref('stg_orders') }} p
order by order_id
