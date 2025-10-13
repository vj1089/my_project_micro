output "LB_Details" {
    value = {
        LB_ID    = aws_lb.this.id
        DNS_Name = aws_lb.this.dns_name
        LB_Name  = aws_lb.this.tags_all["Name"]
        TG_ID    = aws_lb_target_group.this[*].id
        TG_PORT  = aws_lb_target_group.this[*].port
        LIST_ID  = var.load_balancer_type == "application" ? aws_lb_listener.this[*].id : []
        LIST_PORT = var.load_balancer_type == "application" ? aws_lb_listener.this[*].port : []
    }
}


# Listener ARNs and Ports (for ALB)
output "listener_arns" {
    value = var.load_balancer_type == "application" ? aws_lb_listener.this[*].arn : []
}
output "listener_ports" {
    value = var.load_balancer_type == "application" ? aws_lb_listener.this[*].port : []
}