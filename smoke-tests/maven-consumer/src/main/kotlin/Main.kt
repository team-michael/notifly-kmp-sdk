import tech.notifly.kmp.identity.UserIdTransitionPolicy

fun main() {
    check(UserIdTransitionPolicy.evaluate(null, "A").shouldMerge)
}
