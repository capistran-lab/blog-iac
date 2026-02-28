# 1. Política de Headers para Seguridad (Arregla el 78 en Best Practices)
resource "aws_cloudfront_response_headers_policy" "security_headers" {
  name = "${var.project_name}-security-headers"

  security_headers_config {
    content_type_options {
      override = true
    }
    frame_options {
      frame_option = "DENY"
      override     = true
    }
    referrer_policy {
      referrer_policy = "strict-origin-when-cross-origin"
      override        = true
    }
    xss_protection {
      protection = true
      mode_block = true
      override   = true
    }
    strict_transport_security {
      access_control_max_age_sec = 31536000
      include_subdomains         = true
      preload                    = true
      override                   = true
    }
  }
}

# 2. Origin Access Control (OAC)
resource "aws_cloudfront_origin_access_control" "media_oac" {
  name                              = "${var.project_name}-media-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 3. La Distribución (El recurso que te faltaba)
resource "aws_cloudfront_distribution" "media_distribution" {
  origin {
    domain_name              = aws_s3_bucket.blog_media.bucket_regional_domain_name
    origin_id                = "S3-BlogMedia"
    origin_access_control_id = aws_cloudfront_origin_access_control.media_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CDN for dev-record media"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-BlogMedia"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    
    # Arregla el reporte de Lighthouse: Cache de 1 año para imágenes
    min_ttl                = 0
    default_ttl            = 31536000
    max_ttl                = 31536000
    compress               = true
    
    response_headers_policy_id = aws_cloudfront_response_headers_policy.security_headers.id
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

output "cloudfront_media_url" {
  value = aws_cloudfront_distribution.media_distribution.domain_name
}