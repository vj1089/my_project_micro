output "LB_Details" {
    
    value = {
        LB_ID = aws_lb.alb-dev.id
        DNS_Name =  aws_lb.alb-dev.dns_name        
        LB_Name = aws_lb.alb-dev.tags_all["Name"]
        TG_ID = aws_lb_target_group.alb-dev-tg1[*].id
        TG_PORT = aws_lb_target_group.alb-dev-tg1[*].port
        LIST_ID = aws_lb_listener.dev-listener[*].id
        LIST_PORT =aws_lb_listener.dev-listener[*].port
    }
}

output "ELBID" {
    value = aws_lb_listener.dev-listener[*].tags_all
  
}