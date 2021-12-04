with paid_order as (
    select 
        o.order_id,
        o.customer_id,
        o.order_placed_at,
        o.order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.customer_first_name,
        c.customer_last_name
    from {{ ref('base_orders') }} as o
    left join {{ ref('base_payments') }} p using (order_id)
    left join {{ ref('base_customers') }} c using (customer_id)
), cummulative_value as (
    select
        current_order.order_id,
        sum(prev_orders.total_amount_paid) as cummulative_value
    from paid_order current_order
        left join paid_order prev_orders 
            on current_order.customer_id = prev_orders.customer_id 
                and current_order.order_id >= prev_orders.order_id
    group by 1
    order by current_order.order_id
)
select *
from paid_order 
left join cummulative_value using (order_id)