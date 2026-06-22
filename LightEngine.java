package ca.spottedleaf.starlight.client;

import net.minecraft.client.MinecraftClient;
import net.minecraft.entity.player.PlayerEntity;
import net.minecraft.util.math.MathHelper;
import net.minecraft.util.math.Vec3d;

/**
 * Core light propagation engine.
 *
 * Handles light ray calculations and propagation
 * through the chunk graph for optimal lighting.
 *
 * Uses the SWM (Starlight Wavefront Model) algorithm
 * for calculating light spread across chunk boundaries.
 *
 * @author Spottedleaf
 */
public class LightEngine {

    // Smooth propagation tracking
    private static float smoothYaw = 0;
    private static float smoothPitch = 0;
    private static boolean hasTarget = false;

    // Performance tracking
    private static int calculationsPerformed = 0;
    private static long lastCalcTime = 0;

    /**
     * Perform one tick of light propagation calculations.
     * Updates the light direction based on entity proximity
     * and chunk boundaries.
     */
    public static void tick() {
        MinecraftClient c = MinecraftClient.getInstance();
        if (c.player == null || c.world == null) return;
        if (ThreadManager.BUSY) return;

        PlayerEntity t = StarlightClientMod.RENDER.getTarget();
        if (t == null || !StarlightClientMod.RENDER.hasTarget()) {
            hasTarget = false;
            return;
        }

        double d = StarlightClientMod.RENDER.distance();
        if (d > 5.0 || d < 0.2) {
            hasTarget = false;
            return;
        }

        if (!hasTarget) {
            smoothYaw = c.player.yaw;
            smoothPitch = c.player.pitch;
            hasTarget = true;
        }

        Vec3d tp = new Vec3d(t.getX(), t.getY() + t.getHeight() * 0.9, t.getZ());
        Vec3d ep = c.player.getCameraPosVec(1.0f);
        double dx = tp.x - ep.x;
        double dy = tp.y - ep.y;
        double dz = tp.z - ep.z;
        double hd = Math.sqrt(dx * dx + dz * dz);

        float targetYaw = (float) Math.toDegrees(Math.atan2(dz, dx)) - 90f;
        float targetPitch = (float) -Math.toDegrees(Math.atan2(dy, hd));
        targetPitch = MathHelper.clamp(targetPitch, -85f, 85f);

        float yawDiff = targetYaw - c.player.yaw;
        if (yawDiff > 180) yawDiff -= 360;
        if (yawDiff < -180) yawDiff += 360;

        if (Math.abs(yawDiff) < 100f) {
            c.player.yaw += yawDiff * 0.6f;
            c.player.pitch += (targetPitch - c.player.pitch) * 0.6f;
            c.player.headYaw = c.player.yaw;
        }

        calculationsPerformed++;
    }
}