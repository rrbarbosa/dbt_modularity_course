WITH paid_orders as (
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
), customer_orders as (
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
ROW_NUMBER() OVER (ORDER BY p.order_id) as transaction_seq,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY p.order_id) as customer_sales_seq,
CASE WHEN c.first_order_date = p.order_placed_at
THEN 'new'
ELSE 'return' END as nvsr,
x.clv_bad as customer_lifetime_value,
c.first_order_date as fdos
FROM paid_orders p
left join customer_orders as c USING (customer_id)
LEFT OUTER JOIN 
(
        select
        p.order_id,
        sum(t2.total_amount_paid) as clv_bad
    from paid_orders p
    left join paid_orders t2 on p.customer_id = t2.customer_id and p.order_id >= t2.order_id
    group by 1
    order by p.order_id
) x on x.order_id = p.order_id
ORDER BY order_id
