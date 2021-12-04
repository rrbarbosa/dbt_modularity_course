with customer_orders as (
    select
        customer_id, 
        min(o.order_placed_at) as first_order_date,
        max(o.order_placed_at) as most_recent_order_date,
        count(o.order_id) AS number_of_orders
    from {{ ref('base_customers') }} c 
    left join {{ ref('base_orders') }} as o using (customer_id)
    group by 1
)
select
    p.*,
    row_number() over (order by p.order_id) as transaction_seq,
    row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
    case 
        when c.first_order_date = p.order_placed_at
            then 'new'
        else 'return' 
    end as nvsr,
    p.cummulative_value as customer_lifetime_value,
    c.first_order_date as fdos
from {{ ref('stg_orders') }} p
left join customer_orders as c using (customer_id)
order by order_id
