DiskFlush - HstWB optional user package

Use OS 2.04+ conservatively (Aminet architecture); upstream readme says OS 2.0+. Run DiskFlush manually to request pending disk writes. VERBOSE shows operations; LISTFAILED reports failed devices. Return codes: 0 success, 5 partial failure, 20 failure. Do not automatically reboot after failure. Filesystem/device support and physical persistence require target testing; success is not a guarantee against power-loss data loss. HstWB does not execute DiskFlush or modify reboot scripts.

The complete original archive is extracted into this drawer. Existing drawers
with Upstream-README.txt are retained without overwriting settings or files.
Setup remains manual; consult Upstream-README.txt and the original manuals.
Original archive and license notices are retained. Updates require review.
