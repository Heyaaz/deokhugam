package com.codeit.duckhu.domain.comment.repository;

import com.codeit.duckhu.domain.comment.domain.Comment;
import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CommentRepository extends JpaRepository<Comment, UUID>, CommentCustomRepository {

  List<Comment> findByReview_Id(UUID reviewId);

  // 삭제되지 않은 댓글만 조회
  List<Comment> findByReview_IdAndIsDeletedFalse(UUID reviewId);

  // 특정 리뷰에 대한 댓글 수를 계산
  int countByReviewIdAndIsDeletedFalse(UUID reviewId);
}
