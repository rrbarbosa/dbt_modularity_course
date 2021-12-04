-- TODO: review names and cleanup in customer_values_v2
with paid_orders as (
    select 
        o.order_id,
        o.customer_id,
        o.order_placed_at,
        o.order_status,
        p.total_amount_paid,
        p.payment_finalized_date,
        c.customer_first_name,
        c.customer_last_name,
        row_number() over (order by p.order_id) as transaction_seq,
        row_number() over (partition by customer_id order by p.order_id) as customer_sales_seq,
        min(order_placed_at) over (partition by customer_id order by p.order_id rows unbounded preceding) as first_order_date,
        sum(total_amount_paid) over (partition by customer_id order by p.order_id rows unbounded preceding) as cummulative_amount_paid
    from {{ ref('base_orders') }} as o
    left join {{ ref('base_payments') }} p using (order_id)
    left join {{ ref('base_customers') }} c using (customer_id)
)
select 
    *,
    case 
        when customer_sales_seq = 1 then 'new'
        else 'return' 
    end as nvsr
from paid_orders