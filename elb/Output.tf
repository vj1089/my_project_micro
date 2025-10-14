output "LB_Details" {
    value = {
        LB_ID    = aws_lb.this.id
        DNS_Name = aws_lb.this.dns_name
        LB_Name  = aws_lb.this.tags_all["Name"]
        TG_ID    = aws_lb_target_group.this[*].id
        TG_PORT  = aws_lb_target_group.this[*].port
        LIST_ID  = aws_lb_listener.this[*].id
        LIST_PORT = aws_lb_listener.this[*].port
    }
}


# Listener ARNs and Ports (for ALB)
output "listener_arns" {
    value = aws_lb_listener.this[*].arn
}
output "listener_ports" {
    value = aws_lb_listener.this[*].port
}