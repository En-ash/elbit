output "eks_id"{
    value = aws_eks_cluster.this.id
}

output "eks_name"{
    value = aws_eks_cluster.this.name
}