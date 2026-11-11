package com.cybershield.filter;

import com.cybershield.util.CsrfUtil;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class CsrfFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if ("POST".equalsIgnoreCase(httpRequest.getMethod())
                && !CsrfUtil.isValid(httpRequest)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Invalid or expired security token. Please refresh the page and try again.");
            return;
        }

        chain.doFilter(request, response);
    }
}
