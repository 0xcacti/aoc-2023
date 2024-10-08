(ql:quickload "cl-ppcre")

;; use dict that maps node to all the nodes it can go to 
;; key is start and set is all the possible destinations

(defun read-input (is-test)
  (let* ((input-file (if is-test "test-input.txt" "input.txt"))
         (path (merge-pathnames input-file #P"~/code/challenges/aoc/2021/lisp/12/"))
         (caves (make-hash-table :test 'equal)))
    (with-open-file (stream path :direction :input)
      (loop for line = (read-line stream nil)
            while line do 
              (let ((line-array (cl-ppcre:split "-" line)))
                (push (second line-array) (gethash (first line-array) caves '()))
                (push (first line-array) (gethash (second line-array) caves '())))))
    caves))

(read-input t)

(defun print-map(caves) 
    (maphash (lambda (k v) (format t "~a->~a~%" k v)) caves))

(print-map (read-input t))

(defun is-lower (s)
  "Check if string s is all lowercase"
  (string= s (string-downcase s)))

(defun is-upper (s)
  "Check if string s is all lowercase"
  (string= s (string-upcase s)))


(defun solve-one ()
  "Solution to day 12, part one"
  (let* ((caves (read-input nil))
         (todo '())  ;; This will hold paths as lists of caves
         (all-paths (make-hash-table :test 'equal)))  ;; Use a hash table instead of a list
    (push '("start") todo)  ;; Push a list containing "start"
    (loop while todo
          do (let* ((path (pop todo))  ;; Pop the path (which is a list of caves)
                    (current (elt path (1- (length path)))))  ;; Get the last cave in the path using elt
               (format t "Processing path: ~a, Current: ~a~%" path current)
               (when (string= current "end")
                 (setf (gethash (format nil "~{~a~^,~}" path) all-paths) t)  ;; Add path to hash table
                 (continue))  ;; Continue to next iteration if we've reached the end
               (let ((connections (gethash current caves)))
                 (format t "Connections for ~a: ~a~%" current connections)
                 (loop for next in connections
                       do (format t "considering next: ~a~%" next)
                       when (or (not (is-lower next)) (not (member next path :test #'string=)))
                       do (push (append path (list next)) todo)))))
    (hash-table-count all-paths)))  ;; Return the count of unique paths
(solve-one)



(defun solve-two ()
  "Solution to day 12, part two"
  (let* ((caves (read-input nil))
         (todo '())
         (done (make-hash-table :test 'equal)))
    (push '(("start") nil) todo)
    (loop while todo
          do (let* ((path-with-revisit (pop todo))
                    (path (first path-with-revisit))
                    (double-small (second path-with-revisit))
                    (current (car (last path))))
               (if (string= current "end")
                   (setf (gethash path done) t)
                   (let ((connections (gethash current caves)))
                     (loop for next in connections
                           do (cond
                                ((string= next "start")
                                 (continue))
                                ((is-upper next)
                                 (push (list (append path (list next)) double-small) todo))
                                ((not (member next path :test #'string=))
                                 (push (list (append path (list next)) double-small) todo))
                                ((and (not double-small) (= (count next path :test #'string=) 1))
                                 (push (list (append path (list next)) t) todo))))))))
    (hash-table-count done)))

(defun is-upper (s)
  (every #'upper-case-p s))

(solve-two)
