package com.codeit.duckhu.config;

import com.github.benmanes.caffeine.cache.Caffeine;
import java.time.Duration;
import java.util.Arrays;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.Cache;
import org.springframework.cache.CacheManager;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.cache.caffeine.CaffeineCacheManager;
import org.springframework.cache.interceptor.CacheErrorHandler;
import org.springframework.cache.interceptor.SimpleCacheErrorHandler;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableCaching
@Slf4j
public class CacheConfig {

  @Bean
  public CacheManager cacheManager() {
    CaffeineCacheManager cacheManager = new CaffeineCacheManager();

    // Caffeine 캐시 설정
    cacheManager.setCaffeine(Caffeine.newBuilder()
        .maximumSize(1000) // 최대 캐시 크기
        .expireAfterWrite(Duration.ofMinutes(10)) // 10분 후 만료
        .recordStats() // 통계 기록 활성화
        .removalListener((key, value, cause) ->
            log.info("캐시 제거 : 키={}, 값={}, 원인={}", key, value, cause))
        );

    // 캐시 이름 등록
    cacheManager.setCacheNames(Arrays.asList("popularReviews", "reviewStats"));

    return cacheManager;
  }

  @Bean
  public CacheErrorHandler cacheErrorHandler() {
    return new SimpleCacheErrorHandler() {
      @Override
      public void handleCacheGetError(RuntimeException exception, Cache cache, Object key) {
        log.warn("캐시 조회 오류: 키={}, 오류={}", key, exception.getMessage());
        // 에러 발생 시 DB에서 조회하도록 무시
      }

      @Override
      public void handleCachePutError(RuntimeException exception, Cache cache, Object key,
          Object value) {
        log.warn("캐시 저장 오류: 키={}, 값={}, 오류={}", key, value, exception.getMessage());
        // 에러 발생 시 캐시 저장 실패해도 계속 진행
      }
    };
  }
}
