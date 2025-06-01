-- 더미 데이터 생성 스크립트
-- 사용자 1,000명, 도서 500권, 리뷰 10,000개 생성

-- 사용자 더미 데이터 (1,000명)
INSERT INTO users (id, email, nickname, password, is_deleted, created_at)
SELECT
    gen_random_uuid(),
    'user' || generate_series || '@example.com',
    'User' || generate_series,
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- bcrypt encoded 'password'
    false,
    NOW() - INTERVAL '1 year' * random()
FROM generate_series(1, 1000);

-- 도서 더미 데이터 (500권)
INSERT INTO books (id, title, author, description, publisher, published_date, isbn, review_count, rating, is_deleted, created_at)
SELECT
    gen_random_uuid(),
    '도서 제목 ' || generate_series || ': ' ||
    CASE (generate_series % 10)
        WHEN 0 THEN '프로그래밍의 정석'
        WHEN 1 THEN '데이터 구조와 알고리즘'
        WHEN 2 THEN '클린 코드'
        WHEN 3 THEN '디자인 패턴'
        WHEN 4 THEN '리팩토링'
        WHEN 5 THEN '소프트웨어 아키텍처'
        WHEN 6 THEN '테스트 주도 개발'
        WHEN 7 THEN '함수형 프로그래밍'
        WHEN 8 THEN '네트워크 프로그래밍'
        ELSE '웹 개발의 기초'
        END,
    CASE (generate_series % 15)
        WHEN 0 THEN '김철수'
        WHEN 1 THEN '이영희'
        WHEN 2 THEN '박민수'
        WHEN 3 THEN '정수진'
        WHEN 4 THEN '최영호'
        WHEN 5 THEN '한지민'
        WHEN 6 THEN '오세훈'
        WHEN 7 THEN '임채영'
        WHEN 8 THEN '윤동주'
        WHEN 9 THEN '강감찬'
        WHEN 10 THEN '신사임당'
        WHEN 11 THEN '장영실'
        WHEN 12 THEN '세종대왕'
        WHEN 13 THEN '이순신'
        ELSE '홍길동'
        END,
    '이 책은 ' ||
    CASE (generate_series % 5)
        WHEN 0 THEN '초보자를 위한 입문서입니다. 기본 개념부터 차근차근 설명하여 누구나 쉽게 따라할 수 있습니다.'
        WHEN 1 THEN '실무에서 바로 활용할 수 있는 실용적인 가이드북입니다. 다양한 예제와 함께 깊이 있는 내용을 다룹니다.'
        WHEN 2 THEN '전문가 수준의 고급 내용을 담고 있습니다. 심화 학습을 원하는 독자에게 추천합니다.'
        WHEN 3 THEN '이론과 실습을 균형있게 다룬 종합 교재입니다. 체계적인 학습이 가능합니다.'
        ELSE '최신 트렌드와 실무 노하우가 담긴 필독서입니다. 업계 전문가들이 강력 추천하는 책입니다.'
        END,
    CASE (generate_series % 8)
        WHEN 0 THEN '한빛미디어'
        WHEN 1 THEN '에이콘출판사'
        WHEN 2 THEN '위키북스'
        WHEN 3 THEN '길벗'
        WHEN 4 THEN '인사이트'
        WHEN 5 THEN '제이펍'
        WHEN 6 THEN '비제이퍼블릭'
        ELSE '영진닷컴'
        END,
    DATE '2020-01-01' + (random() * (DATE '2024-12-31' - DATE '2020-01-01'))::int,
        '978-89-' || LPAD((generate_series % 10000)::text, 4, '0') || '-' || LPAD((generate_series % 100)::text, 2, '0') || '-' || (generate_series % 10),
    0, -- 초기값, 리뷰 생성 후 업데이트
    0.0, -- 초기값, 리뷰 생성 후 업데이트
    false,
    NOW() - INTERVAL '2 years' * random()
FROM generate_series(1, 500);

-- 리뷰 더미 데이터 (10,000개)
-- 한 유저가 한 도서에 하나의 리뷰만 작성 가능하도록 구현
WITH user_book_pairs AS (
    SELECT
        u.id as user_id,
        b.id as book_id,
        ROW_NUMBER() OVER (ORDER BY random()) as rn
    FROM
        (SELECT id FROM users ORDER BY random()) u
            CROSS JOIN
        (SELECT id FROM books ORDER BY random()) b
    ORDER BY random()
    LIMIT 10000
    )
INSERT INTO reviews (id, content, rating, like_count, comment_count, is_deleted, user_id, book_id, created_at)
SELECT
    gen_random_uuid(),
    CASE (ubp.rn % 20)
        WHEN 0 THEN '정말 유익한 책이었습니다. 실무에 바로 적용할 수 있어서 좋았어요.'
        WHEN 1 THEN '초보자도 이해하기 쉽게 설명되어 있어서 추천합니다.'
        WHEN 2 THEN '내용이 너무 어려워서 중급자 이상에게 추천합니다.'
        WHEN 3 THEN '예제가 풍부해서 따라하기 쉬웠습니다. 강력 추천!'
        WHEN 4 THEN '이론적인 부분이 잘 정리되어 있어서 체계적으로 학습할 수 있었습니다.'
        WHEN 5 THEN '실무 경험이 많은 저자의 노하우가 잘 담겨있습니다.'
        WHEN 6 THEN '최신 기술 트렌드를 잘 반영하고 있어서 도움이 되었습니다.'
        WHEN 7 THEN '코드 품질 향상에 많은 도움이 되었습니다.'
        WHEN 8 THEN '개념 설명이 명확하고 예시가 적절해서 이해하기 쉬웠습니다.'
        WHEN 9 THEN '실제 프로젝트에 적용해봤는데 정말 유용했습니다.'
        WHEN 10 THEN '기대했던 것보다 내용이 부족해서 아쉬웠습니다.'
        WHEN 11 THEN '번역이 자연스럽고 읽기 편했습니다.'
        WHEN 12 THEN '깊이 있는 내용까지 다루고 있어서 전문성을 높일 수 있었습니다.'
        WHEN 13 THEN '단계별로 차근차근 설명해주어서 학습하기 좋았습니다.'
        WHEN 14 THEN '실무에서 자주 마주치는 문제들의 해결방법이 잘 나와있습니다.'
        WHEN 15 THEN '기본기를 탄탄하게 다질 수 있는 좋은 책입니다.'
        WHEN 16 THEN '복잡한 개념을 쉽게 풀어서 설명해주어서 좋았습니다.'
        WHEN 17 THEN '실습 위주의 구성이 마음에 들었습니다.'
        WHEN 18 THEN '이 분야의 필독서라고 생각합니다.'
        ELSE '전반적으로 만족스러운 책이었습니다. 추천합니다.'
        END as content,
    CASE
        WHEN ubp.rn % 100 < 5 THEN 1    -- 5%
        WHEN ubp.rn % 100 < 15 THEN 2   -- 10%
        WHEN ubp.rn % 100 < 35 THEN 3   -- 20%
        WHEN ubp.rn % 100 < 70 THEN 4   -- 35%
        ELSE 5                          -- 30%
        END as rating,
    FLOOR(random() * 50), -- 0~49 좋아요
    FLOOR(random() * 10), -- 0~9 댓글
    false,
    ubp.user_id,
    ubp.book_id,
    NOW() - INTERVAL '1 year' * random()
FROM user_book_pairs ubp;

-- 댓글 더미 데이터 (리뷰의 일부에 댓글 추가)
WITH random_reviews AS (
    SELECT
        r.id as review_id,
        u.id as user_id,
        ROW_NUMBER() OVER (ORDER BY random()) as rn
    FROM reviews r
             CROSS JOIN (SELECT id FROM users ORDER BY random() LIMIT 100) u
    WHERE random() < 0.3 -- 30% 확률로 댓글 생성
    ORDER BY random()
    LIMIT 3000
    )
INSERT INTO comments (id, user_id, review_id, content, is_deleted, created_at)
SELECT
    gen_random_uuid(),
    user_id,
    review_id,
    CASE (rn % 10)
        WHEN 0 THEN '좋은 리뷰 감사합니다!'
        WHEN 1 THEN '저도 이 책 읽어봤는데 정말 좋더라구요.'
        WHEN 2 THEN '궁금했던 책인데 리뷰 보고 구매 결정했습니다.'
        WHEN 3 THEN '상세한 리뷰 덕분에 도움이 되었습니다.'
        WHEN 4 THEN '다른 관점에서도 흥미로운 책이네요.'
        WHEN 5 THEN '추천해주신 부분 특히 유용했습니다.'
        WHEN 6 THEN '리뷰어님과 비슷한 생각이네요.'
        WHEN 7 THEN '이런 책도 있다는걸 처음 알았어요.'
        WHEN 8 THEN '자세한 설명 감사드립니다.'
        ELSE '유익한 리뷰였습니다!'
        END,
    false,
    NOW() - INTERVAL '6 months' * random()
FROM random_reviews;

-- 리뷰 좋아요 더미 데이터
WITH random_likes AS (
    SELECT DISTINCT ON (r.id, u.id)
    r.id as review_id,
    u.id as user_id
FROM reviews r
    CROSS JOIN (SELECT id FROM users ORDER BY random() LIMIT 200) u
WHERE random() < 0.4
ORDER BY r.id, u.id
    LIMIT 15000
    )
INSERT INTO review_likes (id, review_id, user_id, created_at)
SELECT
    gen_random_uuid(),
    review_id,
    user_id,
    NOW() - INTERVAL '6 months' * random()
FROM random_likes;