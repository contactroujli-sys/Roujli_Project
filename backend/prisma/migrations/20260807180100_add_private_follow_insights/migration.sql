/*
  Warnings:

  - You are about to drop the column `updatedAt` on the `BusinessInsight` table. All the data in the column will be lost.

*/
-- CreateEnum
CREATE TYPE "public"."FollowStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');

-- AlterEnum
ALTER TYPE "public"."NotificationType" ADD VALUE 'FOLLOW_REQUEST';

-- DropIndex
DROP INDEX "public"."BusinessInsight_category_idx";

-- AlterTable
ALTER TABLE "public"."BusinessFollow" ADD COLUMN     "status" "public"."FollowStatus" NOT NULL DEFAULT 'PENDING';

-- AlterTable
ALTER TABLE "public"."BusinessInsight" DROP COLUMN "updatedAt";

-- AlterTable
ALTER TABLE "public"."User" ADD COLUMN     "isPrivate" BOOLEAN NOT NULL DEFAULT false;
