# AI usage: dsc26-flt-w06

AI tools are allowed in this task. Fill in every section in your own words. This file is read by your Track Mentor, not by the grader.

## 1. Tools I used

I used GitHub Copilot, the repository README and public tests, and Flutter's test/analyzer commands.

## 2. My best prompts

<!-- Paraphrasing is fine. -->

1. Implement the starter TODOs according to the README's exact behavior and signatures.
2. Verify the SHA-256 evidence record, population Laplacian variance, and permission request counts.

## 3. One place the assistant got the maths or the permission rules wrong

No incorrect behavior remained in the implementation. I specifically checked that sharpness uses population variance (division by `n`, not `n - 1`) against the README and checkerboard test.

## 4. Phone or server: Wiqaya's guided capture

I would run camera permission handling, image-quality checks, and capture guidance on the phone so the claimant gets immediate feedback without uploading unusable images. I would verify hashes and evidence metadata on the server as well, because server-side validation provides a trusted record that cannot rely solely on client behavior.
